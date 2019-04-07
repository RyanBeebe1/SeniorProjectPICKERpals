import configparser
import json
import os
import MySQLdb
from PIL import Image
from sqlalchemy.sql import func
from flask import Flask, jsonify, request, send_from_directory
from flask_marshmallow import Marshmallow
from flask_sqlalchemy import SQLAlchemy
from flask_uploads import IMAGES, UploadSet, configure_uploads
from pyfcm import FCMNotification

app = Flask(__name__)

#Configure image uploading
UPLOAD_FOLDER = os.path.basename('images')
photos = UploadSet('photos', IMAGES)
app.config['UPLOADED_PHOTOS_DEST'] = UPLOAD_FOLDER
configure_uploads(app, photos)

#Configure Firebase Push Service
push_service = FCMNotification(api_key = "<AAAAQ66RqbM:APA91bEc1XP3s3qW1PQ2TueB0b20taMD0Kt8lUBMGicMeeYaQccw1lws_OJboLAy_7t-J2ACEcZa-sHlq71Ty7wBjrd3bm5yw51CPjPefl5Fzyh7WTsBYZH9psfg2pc7uUS4sPsmlI7A>")
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
    rating_id = db.Column('rating_id', db.Integer, primary_key=True)
    rating = db.Column('rating', db.Integer)
    listing_id = db.Column('listing_id',db.Integer)
    user_id = db.Column('user_id',db.Integer)

    def __init__(self, rating, listingid, userid):
        self.rating = ratingid
        self.listing_id = listingid
        self.user_id = userid


class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column('user_id', db.Integer, primary_key=True)
    email_address = db.Column('email',db.String(50))
    display_name = db.Column('display_name',db.String(50))
    token_id = db.Column('tokenid',db.String(200))
    fb_uid = db.Column('fb_uid', db.String(200))
    overall_rating = db.Column('overall_rating', db.Integer)
    

    def __init__(self, emailaddress, displayname, tokenid, uid):
        self.email_address = emailaddress
        self.display_name = displayname
        self.token_id = tokenid
        self.fb_uid = uid

class DesiredItem(db.Model):
    __tablename__ = 'desired_item'
    desired_item_id = db.Column('desired_item_id', db.Integer, primary_key=True)
    user_id = db.Column('user_id', db.Integer)
    keyword = db.Column('keyword',db.String(45))

    def __init__(self, userid, keyword):
        self.user_id = userid
        self.keyword = keyword

class Images(db.Model):
    __tablename__ = 'images'
    image_name = db.Column('image_name', db.String(200), primary_key = True)
    listing_id = db.Column('listing_id', db.Integer, db.ForeignKey('listing.listing_id'), nullable = False)
    thumbnail = db.Column('thumbnail', db.String(200))

    def __init__(self, name, thumbname, listingid):
        self.image_name = name
        self.thumbnail = thumbname
        self.listing_id = listingid


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
        fields = ('image_name', 'thumbnail', 'listing_id')

class UserSchema(ma.Schema):
    class Meta:
        fields = ('user_id', 'email_address', 'display_name', 'token_id','overall_rating', 'fb_uid')

class DesiredItemSchema(ma.Schema):
    class Meta:
        fields = ('desired_item_id','user_id','keyword')


# Init Schema
listing_schema = ListingSchema(strict = True)
listings_schema = ListingSchema(many = True, strict = True)

image_schema = ImageSchema(strict=True)
images_schema = ImageSchema(many = True, strict = True)

rating_schema = RatingSchema(strict = True)
ratings_schema = RatingSchema(many = True, strict = True)

user_schema  = UserSchema(strict = True)
users_schema = UserSchema(many = True, strict = True)

desired_item_schema = DesiredItemSchema(strict = True)
desired_items_schema = DesiredItemSchema(many = True, strict = True)

# Unfinished
def check_desired_items(description):
    listings = Listing.query.filter(Listing.description.like("%"+description+"%"))
    list_dump = listings_schema.dump(all_listings)
    for listing in list_dump:
        print(listing)

## APP ENDPOINTS:

# Add new user
@app.route('/adduser', methods=['POST'])
def add_user():
    email = request.json['email_address']
    name = request.json['display_name']
    tokenid = request.json['token_id']
    uid = request.json['fb_uid']
    new_user = User(email, name, tokenid, uid)
    db.session.add(new_user)
    db.session.commit()
    return listing_schema.jsonify(new_user)

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

# Add desired item
@app.route('/adddesireditem', methods=['POST'])
def add_desired_item():
    user_id = request.json['user_id']
    tag = request.json['tag']
    new_desired_item = DesiredItem(user_id, tag)
    db.session.add(new_desired_item)
    db.session.commit()
    return listing_schema.jsonify(new_desired_item)

#Upload image
@app.route('/upload/<listingid>', methods = ['POST'])
def upload_image(listingid):
    # Save image and get name
    photo = photos.save(request.files['photo'])
    imagename = os.path.basename(photo)
    
    ## Make Image object and thumbnail
    thumbnail_image = Image.open(f'{UPLOAD_FOLDER}/{imagename}')
    thumbnail_image.thumbnail((100,100))
    thumbnail_name = f'{imagename}_thumbnail.jpg'
    thumbnail_image.save(f'{UPLOAD_FOLDER}/{thumbnail_name}')
    
     ## Add Image object to database
    new_image = Images(imagename,thumbnail_name,listingid)
    db.session.add(new_image)
    db.session.commit()
    return imagename

# Get image from listing
@app.route('/images/<listingid>', methods = ['GET'])
def get_image(listingid):
    photo = Images.query.filter(Images.listing_id == listingid).first()
    return send_from_directory(UPLOAD_FOLDER,photo.image_name)

# Get image thumbnail from listing
@app.route('/thumbs/<listingid>', methods = ['GET'])
def get_image_thumbnail(listingid):
    
    photo = Images.query.filter(Images.listing_id == listingid).first()
    return send_from_directory(UPLOAD_FOLDER,photo.thumbnail)

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
    listing.views += 1
    db.session.commit()
    return listing_schema.jsonify(listing)

# Get desired item by id
@app.route('/getdesireditem/<desired_item_id>', methods = ['GET'])
def get_desired_item_byid(desired_item_id):
    desired_item = DesiredItem.query.get(desired_item_id)
    return desired_item_schema.jsonify(desired_item)

# Get all desired items by user id
@app.route('/desireditems/<user_id>', methods = ['GET'])
def get_user_desitems(user_id):
    items = DesiredItem.query.filter(DesiredItem.user_id == user_id)
    results = desired_items_schema.dump(items)
    return jsonify(results.data)

# Get listings by zipcode
@app.route('/listingsbyzip/<zipcode>', methods = ['GET'])
def get_listingsbyzip(zipcode):
    listings = Listing.query.filter(Listing.zipcode == zipcode)
    results = listings_schema.dump(listings)
    return jsonify(results.data)

# Get listings by tag
@app.route('/listingsbytag/<tag>', methods = ['GET'])
def get_listingsbytag(tag):
    listings = Listing.query.filter(Listing.tag == tag)
    results = listings_schema.dump(listings)
    return jsonify(results.data)

# Get a Users listings with their email
@app.route('/listingbyuser/<email>', methods = ['GET'])
def get_listingsbyuseremail(email):
    listings = Listing.query.filter(Listing.userid == email)
    results = listings_schema.dump(listings)
    return jsonify(results.data)

# Delete listing
@app.route('/deletelisting/<listingid>', methods = ['GET'])
def deletelisting(listingid):
    listing = Listing.query.get(listingid)
    ## TODO implement code to delete image from DB and folder
    db.session.delete(listing)
    db.session.commit()
    return "Operation successful"

# Delete desired item
@app.route('/deletedesireditem/<desired_item_id>', methods = ['GET'])
def deletedesireditem(desired_item_id):
    desired_item = DesiredItem.query.get(desired_item_id)
    db.session.delete(desired_item)
    db.session.commit()
    return "Operation successful"

@db.event.listens_for(Listing, "after_insert")
def alert_user():
    return "test"


# The hello world endpoint
@app.route("/hello")
def hello_endpoint():
    return "Hello world!"

if __name__ == "__main__":
    # app.run()
    app.run(host='0.0.0.0', port=5000)