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

# Configure image uploading
UPLOAD_FOLDER = os.path.basename("images")
photos = UploadSet("photos", IMAGES)
app.config["UPLOADED_PHOTOS_DEST"] = UPLOAD_FOLDER
configure_uploads(app, photos)

# app.debug = True
config = configparser.ConfigParser()
config.read("./config.ini")
hostname = config.get("config", "hostname")
username = config.get("config", "username")
database = config.get("config", "database")
password = config.get("config", "password")
firebase_api = config.get("config", "api_key")

# Configure Firebase Push Service
push_service = FCMNotification(api_key=firebase_api)

# SQL-Alchemy settings
app.config[
    "SQLALCHEMY_DATABASE_URI"
] = f"mysql://{username}:{password}@{hostname}/{database}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Init DB
db = SQLAlchemy(app)

# Init marshmallow
ma = Marshmallow(app)

## SQLAlchemy DB classes(map db tables to python objects)
class Listing(db.Model):
    __tablename__ = "listing"
    listingid = db.Column("listing_id", db.Integer, primary_key=True)
    views = db.Column("views", db.Integer, default=0)
    description = db.Column("description", db.String(120))
    location = db.Column("location", db.String(200))
    date = db.Column("listing_date", db.DateTime)
    zipcode = db.Column("zip_code", db.String(5))
    userid = db.Column(
        "user_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    title = db.Column("item_title", db.String(45))
    tag = db.Column("tag", db.String(45))
    condition = db.Column("cond", db.String(45))
    user = db.relationship("User", backref="user")

    def __init__(
        self, description, location, date, zipcode, userid, title, tag, condition
    ):
        self.description = description
        self.location = location
        self.date = date
        self.zipcode = zipcode
        self.userid = userid
        self.title = title
        self.tag = tag
        self.condition = condition


class Rating(db.Model):
    __tablename__ = "rating"
    rating_id = db.Column("rating_id", db.Integer, primary_key=True)
    rating = db.Column("rating", db.Integer)
    listing_id = db.Column("listing_id", db.Integer)
    user_id = db.Column("user_id", db.Integer)

    def __init__(self, rating, listingid, userid):
        self.rating = ratingid
        self.listing_id = listingid
        self.user_id = userid


class User(db.Model):
    __tablename__ = "users"
    user_id = db.Column("user_id", db.Integer, primary_key=True)
    email_address = db.Column("email", db.String(50))
    display_name = db.Column("display_name", db.String(50))
    token_id = db.Column("token_id", db.String(1500))
    fb_uid = db.Column("fb_uid", db.String(200))
    overall_rating = db.Column("overall_rating", db.Integer)

    def __init__(self, emailaddress, displayname, tokenid, uid):
        self.email_address = emailaddress
        self.display_name = displayname
        self.token_id = tokenid
        self.fb_uid = uid

    ## Send push notification to user
    def notify(self, title, body, data):
        result = push_service.notify_single_device(
            registration_id=self.token_id,
            message_title=title,
            message_body=body,
            data_message=data,
            click_action="FLUTTER_NOTIFICATION_CLICK",
        )
        print(f"Push sent to {self.display_name} at {self.token_id} when {result}")


class DesiredItem(db.Model):
    __tablename__ = "desired_item"
    desired_item_id = db.Column("desired_item_id", db.Integer, primary_key=True)
    user_id = db.Column(
        "user_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    keyword = db.Column("keyword", db.String(45))
    found_listing_id = db.Column("found_listing_id", db.Integer)

    def __init__(self, userid, keyword):
        self.user_id = userid
        self.keyword = keyword


class Images(db.Model):
    __tablename__ = "images"
    image_name = db.Column("image_name", db.String(200), primary_key=True)
    listing_id = db.Column(
        "listing_id", db.Integer, db.ForeignKey("listing.listing_id"), nullable=False
    )
    thumbnail = db.Column("thumbnail", db.String(200))

    def __init__(self, name, thumbname, listingid):
        self.image_name = name
        self.thumbnail = thumbname
        self.listing_id = listingid


class Chat(db.Model):
    _tablename__ = "chat"
    chat_id = db.Column("chat_id", db.Integer, primary_key=True)
    sender_id = db.Column(
        "sender_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    recipient_id = db.Column(
        "receiver_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    sentuser = db.relationship("User", backref="sentuser", foreign_keys=[sender_id])
    receiveduser = db.relationship(
        "User", backref="receiveduser", foreign_keys=[recipient_id]
    )

    def __init__(self, sender, receiver):
        self.sender_id = sender
        self.recipient_id = receiver


class Messages(db.Model):
    __tablename__ = "message"
    message_id = db.Column("message_id", db.Integer, primary_key=True)
    body = db.Column("body", db.String(300), nullable=False)
    date = db.Column("date", db.DateTime, nullable=False)
    chat_id = db.Column(
        "chat_id", db.Integer, db.ForeignKey("chat.chat_id"), nullable=False
    )
    chat = db.relationship("Chat", backref="chat", foreign_keys=[chat_id])

    def __init__(self, body, date, chat):
        self.body = body
        self.date = date
        self.chat_id = chat


# Listing shcemas (what fields to serve when pulling from database)
class ListingSchema(ma.Schema):
    class Meta:
        fields = (
            "listingid",
            "views",
            "description",
            "location",
            "date",
            "zipcode",
            "title",
            "tag",
            "condition",
            "user",
        )

    user = ma.Nested("UserSchema", exclude=("token_id", "fb_uid", "user_id"))


class RatingSchema(ma.Schema):
    class Meta:
        fields = ("ratingid", "rating", "listingid", "userid")


class ImageSchema(ma.Schema):
    class Meta:
        fields = ("image_name", "thumbnail", "listing_id")


class UserSchema(ma.Schema):
    class Meta:
        fields = (
            "user_id",
            "email_address",
            "display_name",
            "token_id",
            "overall_rating",
            "fb_uid",
        )


class DesiredItemSchema(ma.Schema):
    class Meta:
        fields = ("desired_item_id", "user_id", "keyword", "found_listing_id")


class ChatSchema(ma.Schema):
    class Meta:
        fields = ("chat_id", "sentuser", "receiveduser")

    sentuser = ma.Nested("UserSchema", exclude=("token_id", "fb_uid", "user_id"))
    receiveduser = ma.Nested("UserSchema", exclude=("token_id", "fb_uid", "user_id"))


class MessageSchema(ma.Schema):
    class Meta:
        fields = ("message_id", "body", "date", "chat")

    chat = ma.Nested("ChatSchema")


# Init Schema
listing_schema = ListingSchema(strict=True)
listings_schema = ListingSchema(many=True, strict=True)

image_schema = ImageSchema(strict=True)
images_schema = ImageSchema(many=True, strict=True)

rating_schema = RatingSchema(strict=True)
ratings_schema = RatingSchema(many=True, strict=True)

user_schema = UserSchema(strict=True)
users_schema = UserSchema(many=True, strict=True)

desired_item_schema = DesiredItemSchema(strict=True)
desired_items_schema = DesiredItemSchema(many=True, strict=True)

chat_schema = ChatSchema(strict=True)
chats_schema = ChatSchema(many=True, strict=True)

message_schema = MessageSchema(strict=True)
messages_schema = MessageSchema(many=True, strict=True)

# Checks all desired items against newly added listing, then notifies all users of result
def new_listing_desire_check(listing):
    desired_items = DesiredItem.query.filter(listing.tag == DesiredItem.keyword)
    for di in desired_items:
        user = User.query.get(di.user_id)
        title = "Desired item alert"
        body = f"A desired item matching {di.keyword} has just been uploaded, claim it now!"
        data = {
            "Listing": f"{listing.listingid}",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        user.notify(title, body, data)


# Notify user of new message
def message_notify(sender, recipient):
    receiver = User.query.get(recipient)
    sender = User.query.get(sender)
    title = f"New message from {sender.display_name}"
    body = "Click to see message"
    # Add whatever data is neccessary
    data = {
        "sender_id": f"{sender.user_id}",
        "recipient_id": f"{receiver.user_id}",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
    }
    receiver.notify(title, body, data)


## APP ENDPOINTS:

# Add new user
@app.route("/adduser", methods=["POST"])
def add_user():
    anobj = User.query.filter(User.fb_uid == request.json["fb_uid"]).first()
    if anobj == None:
        email = request.json["email_address"]
        name = request.json["display_name"]
        tokenid = request.json["token_id"]
        uid = request.json["fb_uid"]
        new_user = User(email, name, tokenid, uid)
        db.session.add(new_user)
        db.session.commit()
    else:
        return user_schema.jsonify(anobj)
    return user_schema.jsonify(new_user)


# Add listing
@app.route("/addlisting", methods=["POST"])
def add_listing():
    userid = request.json["userid"]
    description = request.json["description"]
    location = request.json["location"]
    date = request.json["date"]
    zipcode = request.json["zipcode"]
    title = request.json["title"]
    tag = request.json["tag"]
    condition = request.json["condition"]
    new_listing = Listing(
        description, location, date, zipcode, userid, title, tag, condition
    )
    db.session.add(new_listing)
    db.session.commit()
    new_listing_desire_check(new_listing)
    return listing_schema.jsonify(new_listing)


# Add desired item
@app.route("/adddesireditem", methods=["POST"])
def add_desired_item():
    user_id = request.json["user_id"]
    keyword = request.json["keyword"]
    new_desired_item = DesiredItem(user_id, keyword)
    db.session.add(new_desired_item)
    db.session.commit()
    return desired_item_schema.jsonify(new_desired_item)


# Upload image
@app.route("/upload/<listingid>", methods=["POST"])
def upload_image(listingid):
    # Save image and get name
    photo = photos.save(request.files["photo"])
    imagename = os.path.basename(photo)

    ## Make Image object and thumbnail
    thumbnail_image = Image.open(f"{UPLOAD_FOLDER}/{imagename}")
    thumbnail_image.thumbnail((60, 60))
    thumbnail_name = f"{imagename}_thumbnail.jpg"
    thumbnail_image.save(f"{UPLOAD_FOLDER}/{thumbnail_name}")

    ## Add Image object to database
    new_image = Images(imagename, thumbnail_name, listingid)
    db.session.add(new_image)
    db.session.commit()
    return imagename


# Get image from listing
@app.route("/images/<listingid>", methods=["GET"])
def get_image(listingid):
    photo = Images.query.filter(Images.listing_id == listingid).first()
    if photo is None:
        return "Not found"
    return send_from_directory(UPLOAD_FOLDER, photo.image_name)


# Get image thumbnail from listing
@app.route("/thumbs/<listingid>", methods=["GET"])
def get_image_thumbnail(listingid):
    photo = Images.query.filter(Images.listing_id == listingid).first()
    if photo is None:
        return "Not found"
    return send_from_directory(UPLOAD_FOLDER, photo.thumbnail)


# Get all listings
@app.route("/listings", methods=["GET"])
def get_listings():
    all_listings = Listing.query.all()
    results = listings_schema.dump(all_listings)
    return jsonify(results.data)


# Get a user by id
@app.route("/userbyid/<userid>")
def get_userbyid(userid):
    user = User.query.get(userid)
    db.session.commit()
    return user_schema.jsonify(user)


# Get listing by id
@app.route("/listingbyid/<listingid>", methods=["GET"])
def get_listingbyid(listingid):
    listing = Listing.query.get(listingid)
    listing.views += 1
    db.session.commit()
    return listing_schema.jsonify(listing)


# Get desired item by id
@app.route("/getdesireditem/<desired_item_id>", methods=["GET"])
def get_desired_item_byid(desired_item_id):
    desired_item = DesiredItem.query.get(desired_item_id)
    return desired_item_schema.jsonify(desired_item)


# Get all desired items by user id
@app.route("/desireditems/<user_id>", methods=["GET"])
def get_user_desitems(user_id):
    items = DesiredItem.query.filter(DesiredItem.user_id == user_id)
    results = desired_items_schema.dump(items)
    return jsonify(results.data)


# Get listings by zipcode
@app.route("/listingsbyzip/<zipcode>", methods=["GET"])
def get_listingsbyzip(zipcode):
    listings = Listing.query.filter(Listing.zipcode == zipcode)
    results = listings_schema.dump(listings)
    return jsonify(results.data)


# Get listings by tag
@app.route("/listingsbytag/<tag>", methods=["GET"])
def get_listingsbytag(tag):
    listings = Listing.query.filter(Listing.tag == tag)
    results = listings_schema.dump(listings)
    return jsonify(results.data)


# Get a Users listings with their email
@app.route("/listingbyuser/<email>", methods=["GET"])
def get_listingsbyuseremail(email):
    listings = Listing.query.filter(User.email_address == email)
    results = listings_schema.dump(listings)
    return jsonify(results.data)


# Delete listing
@app.route("/deletelisting/<listingid>", methods=["GET"])
def deletelisting(listingid):
    listing = Listing.query.get(listingid)
    image = Images.query.filter(Images.listing_id == listingid).first()

    if image is not None:
        os.remove(f"{UPLOAD_FOLDER}/{image.image_name}")
        os.remove(f"{UPLOAD_FOLDER}/{image.thumbnail}")
        db.session.delete(image)

    db.session.delete(listing)
    db.session.commit()
    return "Operation successful"


# Delete desired item
@app.route("/deletedesireditem/<desired_item_id>", methods=["GET"])
def deletedesireditem(desired_item_id):
    desired_item = DesiredItem.query.get(desired_item_id)
    db.session.delete(desired_item)
    db.session.commit()
    return "Operation successful"


# Send message to user
@app.route("/sendmessage", methods=["POST"])
def sendmessage():
    body = request.json["body"]
    date = request.json["date"]
    sender = request.json["sender"]
    recipient = request.json["recipient"]

    # Check if chat exists, if not make new chat
    chat = Chat.query.filter(
        Chat.recipient_id == recipient and Chat.sender_id == sender
    ).first()

    if chat is None:
        new_chat = Chat(sender, recipient)
        db.session.add(new_chat)
        chat_id = (
            Chat.query.filter(
                Chat.recipient_id == recipient and Chat.sender_id == sender
            )
            .first()
            .chat_id
        )
    else:
        chat_id = chat.chat_id

    new_message = Messages(body, date, chat_id)
    db.session.add(new_message)
    db.session.commit()
    # Send Push to Recipient
    message_notify(sender, recipient)
    return "Message Sent"


# Get all of a users active chats
@app.route("/getchats/<user_id>")
def getchats(user_id):
    chats = Chat.query.filter(Chat.recipient_id == user_id)
    result = chats_schema.dump(chats)
    return jsonify(result.data)


# Get all messages from chat
@app.route("/getmessages/<chat_id>")
def getmessages(chat_id):
    messages = Messages.query.filter(Messages.chat_id == chat_id).order_by(
        Messages.date
    )
    result = messages_schema.dump(messages)
    return jsonify(result.data)


# Delete user message

# The hello world endpoint
@app.route("/hello")
def hello_endpoint():
    return "Hello world!"


if __name__ == "__main__":
    # app.run()
    app.run(host="0.0.0.0", port=5000)