import configparser
import json
import os
import MySQLdb
from sqlalchemy.sql import func
from flask import Flask, jsonify, request, send_from_directory
from flask_marshmallow import Marshmallow
from flask_sqlalchemy import SQLAlchemy
from flask_uploads import IMAGES, UploadSet, configure_uploads


app = Flask(__name__)

#Configure image uploading
UPLOAD_FOLDER = os.path.basename('images')
photos = UploadSet('photos', IMAGES)
app.config['UPLOADED_PHOTOS_DEST'] = UPLOAD_FOLDER
configure_uploads(app, photos)

# app.debug = True
config=configparser.ConfigParser()
config.read('./config.ini')
hostname = config.get('config','hostname')
username = config.get('config','username')
database = config.get('config','database')
password = config.get('config','password')

#SQL-Alchemy settings
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://{username}:{password}@{hostname}/{database}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Init DB
db = SQLAlchemy(app)

# Init marshmallow
ma = Marshmallow(app)

## SQLAlchemy DB classes(map db tables to python objects)
#TODO implement tables for Users and Ratings
class Listing(db.Model):
    __tablename__ = 'listing'
    listingid = db.Column('listing_id', db.Integer, primary_key=True)
    views = db.Column('views', db.Integer, default=0)
    description = db.Column('description', db.String(120))
    location = db.Column('location', db.String(200))
    date = db.Column('listing_date', db.DateTime)
    zipcode = db.Column('zip_code', db.String(5))
    userid = db.Column('user_id', db.String(45))
    title = db.Column('item_title', db.String(45))
    tag = db.Column('tag', db.String(45))
    condition = db.Column('cond', db.String(45))
    images = db.relationship('Images', backref='listing', lazy=True)

    def __init__(self, description, location, date, zipcode, userid, title, tag, condition):
        self.description = description
        self.location = location
        self.date = date
        self.zipcode = zipcode
        self.userid = userid
        self.title = title
        self.tag = tag
        self.condition = condition

class Rating(db.Model):
    __tablename__ = 'rating'
    ratingid = db.Column('rating_id', db.Integer, primary_key=True)
    rating = db.Column('rating', db.Integer)
    listingid = db.Column('listing_id',db.Integer)
    userid = db.Column('user_id',db.Integer)

    def __init__(self, rating, listingid, userid):
        self.rating = ratingid
        self.listingid = listingid
        self.userid = userid


class User(db.Model):
    __tablename__ = 'users'
    userid = db.Column('users_id', db.Integer, primary_key=True)
    overallrating = db.Column('overall_rating', db.Integer)
    emailaddress = db.Column('email_address',db.String(45))

    def __init__(self, overallrating, emailaddress):
        self.overallrating = overallrating
        self.emailaddress = emailaddress

class DesiredItem(db.Model):
    __tablename__ = 'desired_item'
    desireditemid = db.Column('desired_item_id', db.Integer, primary_key=True)
    userid = db.Column('user_id', db.Integer)
    keyword = db.Column('keyword',db.String(45))

    def __init__(self, userid, keyword):
        self.userid = userid
        self.keyword = keyword

class Images(db.Model):
    __tablename__ = 'images'
    name = db.Column('image_name', db.String(200), primary_key = True)
    listingid = db.Column('listing_id', db.Integer, db.ForeignKey('listing.listing_id'), nullable = False)
    index = db.Column('image_index', db.Integer, default=0)

    def __init__(self, name, listingid, index):
        self.name = name
        self.listingid = listingid
        self.index = index


# Listing shcemas (what fields to serve when pulling from database)
class ListingSchema(ma.Schema):
    class Meta:
        fields = ('listingid', 'views', 'description', 'location', 'date', 'zipcode', 'userid', 'title', 'tag', 'condition')

class RatingSchema(ma.Schema):
    class Meta:
        fields = ('ratingid','rating','listingid','userid')

# Images shcemas
class ImageSchema(ma.Schema):
    class Meta:
        fields = ('name', 'listingid', 'index')

class UserSchema(ma.Schema):
    class Meta:
        fields = ('userid','overallrating','emailaddress')

class DesiredItemSchema(ma.Schema):
    class Meta:
        fields = ('desireditemid','userid','keyword')


# Init Schema
listing_schema = ListingSchema(strict = True)
listings_schema = ListingSchema(many = True, strict = True)

image_schema = ImageSchema(strict=True)
images_schema = ImageSchema(many = True, strict = True)

rating_schema = RatingSchema(strict = True)
ratings_schema = RatingSchema(many = True, strict = True)

user_schema  = UserSchema(strict = True)
users_scheme = UsersSchema(many = True, strict = True)

desired_item_schema = DesiredItemSchema(strict = True)
desired_item_schemas = DesiredItemSchemas(many = True, strict = True)

## APP ENDPOINTS:

# Add listing 
@app.route('/addlisting', methods=['POST'])
def add_listing():
    userid = request.json['userid']
    description = request.json['description']
    location = request.json['location']
    date = request.json['date']
    zipcode = request.json['zipcode']
    title = request.json['title']
    tag = request.json['tag']
    condition = request.json['condition']
    new_listing = Listing(description,location,date,zipcode,userid,title,tag,condition)
    db.session.add(new_listing)
    db.session.commit()
    return listing_schema.jsonify(new_listing)

#Upload image
@app.route('/uploads/<listingid>/<index>', methods = ['POST'])
def upload_image(listingid,index):
    photo = photos.save(request.files['photo'])
    imagename = os.path.basename(photo)
    new_image = Images(imagename,listingid,index)
    db.session.add(new_image)
    db.session.commit()
    return imagename

# Get image from listing
@app.route('/images/<listingid>/<index>', methods = ['GET'])
def get_image(listingid,index):
    photo = Images.query.filter(Images.listingid == listingid and Images.index == index).first()
    return send_from_directory(UPLOAD_FOLDER,photo.name)

# Return next available listing id 
@app.route('/getnextid/', methods = ['GET'])
def get_next_id():
    nextid = db.session.query(func.max(Listing.listingid)).scalar() + 1
    return f'{nextid}'

# Get all listings
@app.route('/listings', methods = ['GET'])
def get_listings():
    all_listings = Listing.query.all()
    results = listings_schema.dump(all_listings)
    return jsonify(results.data)

# Get listing by id
@app.route('/listingbyid/<listingid>', methods = ['GET'])
def get_listingbyid(listingid):
    listing = Listing.query.get(listingid)
    return listing_schema.jsonify(listing)

# Get listings by zipcode
@app.route('/listingsbyzip/<zipcode>', methods = ['GET'])
def get_listingsbyzip(zipcode):
    listings = Listing.query.filter(Listing.zipcode == zipcode)
    results = listings_schema.dump(listings)
    return jsonify(results.data)

# Increment/Update listing views
@app.route('/incrementview/<listingid>', methods = ['PUT'])
def incrementview(listingid):
    listing = Listing.query.get(listingid)
    listing.views += 1
    db.session.commit()
    return listing_schema.jsonify(listing)

# Get listings by tag
@app.route('/listingsbytag/<tag>', methods = ['GET'])
def get_listingsbytag(tag):
    listings = Listing.query.filter(Listing.tag == tag)
    results = listings_schema.dump(listings)
    return jsonify(results.data)

# Delete listing
@app.route('/deletelisting/<listingid>', methods = ['GET'])
def deletelisting(listingid):
    listing = Listing.query.get(listingid)
    db.session.delete(listing)
    db.session.commit()
    return "Operation successful"

# The hello world endpoint
@app.route("/hello")
def hello_endpoint():
    return "Hello world!"

if __name__ == "__main__":
    # app.run()
    app.run(host='0.0.0.0', port=5000)
