use("admin");
db.createUser(
    {
        user: "",
        pwd: "",
        roles: [
            {
                role: "readWrite",
                db: "xpense_db"
            }
        ]
    }
);

use("xpense_db");
db.createCollection("users");