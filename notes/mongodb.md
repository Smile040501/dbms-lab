# MongoDB

- [MongoDB](#mongodb)
- [Installation](#installation)
  - [MongoDB Service](#mongodb-service)
- [Mongosh](#mongosh)
  - [Connecting](#connecting)
  - [Editor Mode](#editor-mode)
- [Create/Switch to a Database](#createswitch-to-a-database)
- [Creating a User](#creating-a-user)
- [Creating a Collection](#creating-a-collection)
- [Inserting Documents](#inserting-documents)
  - [Horizontal Expansion](#horizontal-expansion)
  - [Nested Objects and Arrays](#nested-objects-and-arrays)
- [Retrieving Documents](#retrieving-documents)
- [Updating Documents](#updating-documents)
  - [Upsert](#upsert)
- [Operators](#operators)
  - [Unset](#unset)
  - [Rename](#rename)
- [Deleting a Document](#deleting-a-document)

# Installation

-   https://www.mongodb.com/docs/manual/installation/
-   **WSL**: https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database

## MongoDB Service

```sh
sudo service mongod start

sudo service mongod status

sudo service mongod restart
```

# Mongosh

## Connecting

```sh
mongosh

# Equivalent to above command
mongosh "mongodb://localhost:27017"

mongosh --port 27017

# We can connect to MongoDB Atlas Cluster also
```

-   By default, we connect to a database named `test`
-   We can specify database in the connection string URI
    ```sh
    mongosh "mongodb://localhost:27017/db1"
    ```

```sh
# Verify current database connection
test> db.getMongo()

# Disconnect from deployment and exit `mongosh`
test> exit
```

## Editor Mode

```sh
test> config.set("editor", "vim")

# Start a new Editing session
test> edit

# Edit a variable
test> var albums = []
test> edit albums

# Edit a Statement
test> edit db.collection.insertMany([])
```

# Create/Switch to a Database

```sh
test> use <dbname>

# List all databases
test> show dbs
```

# Creating a User

```sh
db.createUser({
	user: "UserName",
	pwd: "Password",
	roles: ["readWrite","dbAdmin"]
})
```

# Creating a Collection

```sh
db.createCollection("collectionName")

# List all collections
show collections
```

# Inserting Documents

```sh
# Insert a document
db.<collection>.insertOne({
	key: "value",
    ...
})

# Insert multiple documents
db.<collection>.insertMany([
    {
		key: "value",
        ...
    },
    {
        key: "value",
        ...
    }
])
```

## Horizontal Expansion

```sh
# We can introduce new fields while inserting documents
# which is not already present in previous documents
# Also, it doesn't care about the datatype of the field
db.<collection>.insertOne({
	key: "value",
    ...
    newKey: "val"
})
```

## Nested Objects and Arrays

```sh
db.<collection>.update(
    { key: "value" },  # search key
    { $set: {
        key: {
            innerKey: "innerVal",
            ...
        }
    }}
)

db.<collection>.find({
    "key.innerKey": "innerValue"
})
```

```sh
db.<collection>.update(
    { key: "value" },  # search key
    { $set: { key: ["val1", "val2", ...] } }
)
```

# Retrieving Documents

```sh
# Retrieve all documents
db.<collection>.find().pretty();

# Retrieve a document by search key
db.<collection>.find({ key: "value" }).pretty()

# Retrieve only a specific field
db.<collection>.find(
    { key: "value" },
    { key: 1, _id: 0 }
    # By default, it will always return `_id`
).pretty()
```

# Updating Documents

```sh
db.<collection>.updateOne(
    { key: "value" },  # search key
    {
        # Updated Document Fields
        # If a field is not present, it will be added
        # If we don't provide a field, it will be deleted
    }
)

db.<collection>.updateOne(
    { key: "value" },  # search key
    { $set: { keyToUpdate: "val" } }
    # Will only update the given fields
)

db.<collection>.updateOne(
    { key: "value" },  # search key
    { $inc: {age:2} }  # Increment age by 2
)
```

## Upsert

```sh
# Equivalent to insert + update
db.<collection>.updateOne(
    { key: "value" },  # search key
    { $set: { keyToUpdate: "val" } },
    { upsert: true }
)
```

# Operators

```sh
db.<collection>.find(
    {
        $or: [
            { key: "value" },
            { age: { $lt : 40 } }
        ]
    }
).pretty()
```

## Unset

-   Remove a field from a document

```sh
db.<collection>.updateOne(
    { key: "value" },  # search key
    { $unset: { age: '' } }
)
```

## Rename

```sh
db.<collection>.updateMany(
    {},  # Update all
    {
        $rename: {
            "key": "newKey"
        }
    }
)
```

# Deleting a Document

```sh
db.<collection>.deleteOne(
    { key: "value" },  # search key
)
```
