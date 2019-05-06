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
from sqlalchemy import and_, desc, or_

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
    sender_id = db.Column("sender_id", db.Integer)
    reciever_id = db.Column("reciever_id", db.Integer)

    def __init__(self, rating, listing_id, sender_id, reciever_id):
        self.rating = rating
        self.listing_id = listing_id
        self.sender_id = sender_id
        self.reciever_id = reciever_id


class User(db.Model):
    __tablename__ = "users"
    user_id = db.Column("user_id", db.Integer, primary_key=True)
    email_address = db.Column("email", db.String(50))
    display_name = db.Column("display_name", db.String(50))
    fb_uid = db.Column("fb_uid", db.String(200))
    overall_rating = db.Column("overall_rating", db.Integer)

    def __init__(self, emailaddress, displayname, uid):
        self.email_address = emailaddress
        self.display_name = displayname
        self.fb_uid = uid
        self.overall_rating = 0

    ## Send push notification to all user devices
    def notify(self, title, body, data, click):

        devices = Device.query.filter(self.user_id == Device.user_id).all()

        for device in devices:
            result = push_service.notify_single_device(
                registration_id=device.token_id,
                message_title=title,
                message_body=body,
                data_message=data,
                click_action=click,
            )
            print(
                f"Push sent to {self.display_name} at {device.token_id} when {result}"
            )


class DesiredItem(db.Model):
    __tablename__ = "desired_item"
    desired_item_id = db.Column("desired_item_id", db.Integer, primary_key=True)
    user_id = db.Column(
        "user_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    keyword = db.Column("keyword", db.String(45))
    user = db.relationship("User", backref="desireduser", foreign_keys=[user_id])

    def __init__(self, userid, keyword):
        self.user_id = userid
        self.keyword = keyword


class Images(db.Model):
    __tablename__ = "images"
    image_id = db.Column("image_id", db.Integer, primary_key=True)
    image_name = db.Column("image_name", db.String(200))
    listing_id = db.Column(
        "listing_id", db.Integer, db.ForeignKey("listing.listing_id"), nullable=False
    )
    thumbnail = db.Column("thumbnail", db.String(200))
    listing_image = db.relationship(
        "Listing", backref="listingimage", foreign_keys=[listing_id]
    )

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
    user_id = db.Column(
        "user_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    user = db.relationship("User", backref="sendinguser", foreign_keys=[user_id])

    def __init__(self, body, date, chat, user_id):
        self.body = body
        self.date = date
        self.chat_id = chat
        self.user_id = user_id


class Device(db.Model):
    __tablename__ = "device"
    device_id = db.Column("device_id", db.Integer, primary_key=True)
    user_id = db.Column(
        "user_id", db.Integer, db.ForeignKey("users.user_id"), nullable=False
    )
    token_id = db.Column("token_id", db.String(200), nullable=False)
    device_name = db.Column("device_name", db.String(50))

    def __init__(self, user, token, name):
        self.user_id = user
        self.token_id = token
        self.device_name = name


class ReportedListing(db.Model):
    __tablename__ = "reported_listing"
    case_id = db.Column("case_id", db.Integer, primary_key=True)
    listing_id = db.Column(
        "listing_id", db.Integer, db.ForeignKey("listing.listing_id")
    )
    reportedlisting = db.relationship(
        "Listing", backref="reportedlisting", foreign_keys=[listing_id]
    )

    def __init__(self, listing):
        self.listing_id = listing


class ReportedMessage(db.Model):
    __tablename__ = "reported_message"
    case_id = db.Column("case_id", db.Integer, primary_key=True)
    message_id = db.Column(
        "message_id", db.Integer, db.ForeignKey("message.message_id")
    )
    reportedmessage = db.relationship(
        "Messages", backref="reportedmessage", foreign_keys=[message_id]
    )

    def __init__(self, message):
        self.message_id = message


## Listing shcemas ## (what Json database fields marshmellow will return)
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

    user = ma.Nested("UserSchema", exclude=("token_id", "fb_uid"))


class RatingSchema(ma.Schema):
    class Meta:
        fields = ("rating_id", "rating", "listing_id", "sender_id", "reciever_id")


class UserSchema(ma.Schema):
    class Meta:
        fields = (
            "user_id",
            "email_address",
            "display_name",
            "overall_rating",
            "fb_uid",
        )


class DesiredItemSchema(ma.Schema):
    class Meta:
        fields = ("desired_item_id", "user_id", "keyword", "user")

    user = ma.Nested("UserSchema", exclude=("fb_uid", "user_id", "overall_rating"))


class ChatSchema(ma.Schema):
    class Meta:
        fields = ("chat_id", "sentuser", "receiveduser")

    sentuser = ma.Nested("UserSchema", exclude=("fb_uid"))
    receiveduser = ma.Nested("UserSchema", exclude=("fb_uid"))


class MessageSchema(ma.Schema):
    class Meta:
        fields = ("message_id", "body", "date", "chat", "user")

    chat = ma.Nested("ChatSchema")
    user = ma.Nested("UserSchema")


class DeviceSchema(ma.Schema):
    class Meta:
        fields = ("device_id", "token_id", "device_name", "user")

    user = ma.Nested("UserSchema", exclude=("fb_uid"))


# Init Schemas
listing_schema = ListingSchema(strict=True)
listings_schema = ListingSchema(many=True, strict=True)

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

device_schema = DeviceSchema(strict=True)
devices_schema = DeviceSchema(many=True, strict=True)

## Helper functions ##

# Checks all desired items against newly added listing, then notifies all users of result
def new_listing_desire_check(listing):
    desired_items = DesiredItem.query.filter(
        or_(
            func.lower(listing.description).contains(func.lower(DesiredItem.keyword)),
            func.lower(listing.title).contains(func.lower(DesiredItem.keyword)),
        )
    ).all()
    for di in desired_items:
        user = User.query.get(di.user_id)
        title = "Desired item alert"
        body = f"A desired item matching {di.keyword} has just been uploaded, claim it now!"
        click_action = "FLUTTER_NOTIFICATION_CLICK"
        data = {"Listing": f"{listing.listingid}", "click_action": click_action}
        print(f"Notifying {user.display_name} about {di.keyword}")
        if listing.userid != di.user_id:
            user.notify(title, body, data, click_action)


# Notify user of new message
def message_notify(sender, recipient):
    receiver = User.query.get(recipient)
    sender = User.query.get(sender)
    title = f"New message from {sender.display_name}"
    body = "Click to see message"
    click_action = "FLUTTER_NOTIFICATION_CLICK"
    # Add whatever data is neccessary
    data = {
        "sender_id": f"{sender.user_id}",
        "recipient_id": f"{receiver.user_id}",
        "click_action": click_action,
    }
    print(f"notifying {receiver.display_name}")
    receiver.notify(title, body, data, click_action)


# Check if user device is in the DB, adds if not
def device_check(user, tokenid, devicename):
    user_device = Device.query.filter(
        and_(user.user_id == Device.user_id, tokenid == Device.token_id)
    ).first()
    if user_device is None:
        user_device = Device(user.user_id, tokenid, devicename)
        print(f"Adding new device {devicename}")
        db.session.add(user_device)
        db.session.commit()
    else:
        print("Device already in DB")


## APP ENDPOINTS ##

# Add new user
@app.route("/adduser", methods=["POST"])
def add_user():
    anobj = User.query.filter(User.fb_uid == request.json["fb_uid"]).first()
    tokenid = request.json["token_id"]
    devicename = request.json["device_name"]
    if anobj == None:
        email = request.json["email_address"]
        name = request.json["display_name"]
        uid = request.json["fb_uid"]
        new_user = User(email, name, uid)
        db.session.add(new_user)
        db.session.flush()
        device_check(new_user, tokenid, devicename)
    else:
        device_check(anobj, tokenid, devicename)
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

    # Make Image object and thumbnail
    thumbnail_image = Image.open(f"{UPLOAD_FOLDER}/{imagename}")
    thumbnail_image.thumbnail((60, 60))
    thumbnail_name = f"{imagename}_thumbnail.jpg"
    thumbnail_image.save(f"{UPLOAD_FOLDER}/{thumbnail_name}")

    # Add Image object to database
    new_image = Images(imagename, thumbnail_name, listingid)
    db.session.add(new_image)
    db.session.commit()
    return imagename


# Add rating
@app.route("/addrating", methods=["POST"])
def add_rating():
    rating = request.json["rating"]
    listing_id = request.json["listing_id"]
    sender_id = request.json["sender_id"]
    reciever_id = request.json["reciever_id"]
    new_rating = Rating(rating, listing_id, sender_id, reciever_id)
    db.session.add(new_rating)
    db.session.commit()
    update_overall(reciever_id)
    return rating_schema.jsonify(new_rating)


# Change the rating a user gave a listing
@app.route("/changerating", methods=["POST"])
def change_rating():
    rating = request.json["rating"]
    listing_id = request.json["listing_id"]
    sender_id = request.json["sender_id"]
    reciever_id = request.json["reciever_id"]
    Rating.query.filter(
        Rating.sender_id == sender_id, Rating.listing_id == listing_id
    ).delete()
    new_rating = Rating(rating, listing_id, sender_id, reciever_id)
    db.session.add(new_rating)
    db.session.commit()
    update_overall(reciever_id)
    return rating_schema.jsonify(new_rating)


# Update a user's overall rating
def update_overall(reciever_id):
    average = db.session.query(func.avg(Rating.rating).label("average")).filter(
        Rating.reciever_id == reciever_id
    )
    user = User.query.get(reciever_id)
    user.overall_rating = average
    db.session.commit()


# Get user's overall rating
@app.route("/get_overall/<user_id>", methods=["GET"])
def get_overall(user_id):
    return json.dumps({"value": User.query.get(user_id).overall_rating})


# Get a user's rating they gave to a specific listing
@app.route("/fetch_rating/<sender>/<listing>", methods=["GET"])
def fetch_rating(sender, listing):
    return json.dumps(
        {
            "value": db.session.query(Rating.rating)
            .filter(Rating.sender_id == sender, Rating.listing_id == listing)
            .one()[0]
        }
    )


# Return whether a user has rated a listing already
@app.route("/inquire_rating/<sender>/<listing>", methods=["GET"])
def inquire_rating(sender, listing):
    if (
        db.session.query(Rating.rating)
        .filter(Rating.sender_id == sender, Rating.listing_id == listing)
        .first()
        is None
    ):
        data = {"value": "False"}
    else:
        data = {"value": "True"}
    return json.dumps(data)


# Get image from listing
@app.route("/images/<listingid>", methods=["GET"])
def get_image(listingid):
    photo = Images.query.filter(Images.listing_id == listingid).first()
    if photo is None:
        return send_from_directory(UPLOAD_FOLDER, "noimage.png")
    return send_from_directory(UPLOAD_FOLDER, photo.image_name)


# Get image thumbnail from listing
@app.route("/thumbs/<listingid>", methods=["GET"])
def get_image_thumbnail(listingid):
    photo = Images.query.filter(Images.listing_id == listingid).first()
    if photo is None:
        return send_from_directory(UPLOAD_FOLDER, "noimage_thumbnail.png")
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


# Get a Users listings with their ID
@app.route("/listingbyuser/<user_id>", methods=["GET"])
def get_listingsbyuserid(user_id):
    listings = Listing.query.filter(Listing.userid == user_id)
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
    uid = request.json["user_id"]
    recipient = request.json["recipient"]
    # Check if chat exists, if not make new chat
    chat = Chat.query.filter(
        or_(
            and_(Chat.recipient_id == recipient, Chat.sender_id == sender),
            and_(Chat.recipient_id == sender, Chat.sender_id == recipient),
        )
    ).first()

    if chat == None:
        new_chat = Chat(sender, recipient)
        db.session.add(new_chat)
        chat_id = (
            Chat.query.filter(
                and_(Chat.recipient_id == recipient, Chat.sender_id == sender)
            )
            .first()
            .chat_id
        )
    else:
        chat_id = chat.chat_id

    new_message = Messages(body, date, chat_id, uid)
    db.session.add(new_message)
    db.session.commit()
    # Send Push to Recipient
    message_notify(sender, recipient)
    return "Message Sent"


# Get all of a users active chats
@app.route("/getchats/<user_id>")
def getchats(user_id):
    chats = Chat.query.filter(
        or_(Chat.sender_id == user_id, Chat.recipient_id == user_id)
    )
    result = chats_schema.dump(chats)
    return jsonify(result.data)


# Get all messages from chat
@app.route("/getmessages/<chat_id>")
def getmessages(chat_id):
    messages = Messages.query.filter(Messages.chat_id == chat_id).order_by(
        desc(Messages.date)
    )
    result = messages_schema.dump(messages)
    return jsonify(result.data)


# Get last message from chat
@app.route("/lastmessage/<chat_id>")
def getlastmessage(chat_id):
    messages = (
        Messages.query.filter(Messages.chat_id == chat_id)
        .order_by(desc(Messages.date))
        .first()
    )
    return message_schema.jsonify(messages)


# Report message
@app.route("/reportmessage/<messageid>")
def reportmessage(messageid):
    if ReportedMessage.query.filter(ReportedMessage.message_id == messageid) is None:
        message = ReportedMessage(messageid)
        db.session.add(message)
        db.session.commit()
    else:
        return "Message already Reported"
    return f"Reported Message {messageid}"


# Report listing
@app.route("/reportlisting/<listingid>")
def reportlisting(listingid):
    listing = ReportedListing(listingid)
    db.session.add(listing)
    db.session.commit()
    return f"Reported Listing {listingid}"


# The hello world endpoint
@app.route("/hello")
def hello_endpoint():
    return "Hello world!"


if __name__ == "__main__":
    # app.run()
    app.run(host="0.0.0.0", port=5000)
