// DB name
use("skiRentalDBv2");

// Drop existing collections if they exist
db.clients.drop();

// Schema for clients with embedded reservations and equipment
db.createCollection("clients", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "phone"],
      properties: {
        name: { bsonType: "string" },
        email: { bsonType: "string" },
        phone: { bsonType: "string" },
        reservations: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["equipment", "startDate", "endDate", "totalCost", "status"],
            properties: {
              equipment: {
                bsonType: "array",
                items: {
                  bsonType: "object",
                  required: ["equipmentId", "name", "type", "size", "dailyRate"],
                  properties: {
                    equipmentId: { bsonType: "objectId" },
                    name: { bsonType: "string" },
                    type: { bsonType: "string" },
                    size: { bsonType: "string" },
                    dailyRate: { bsonType: "number" }
                  }
                }
              },
              startDate: { bsonType: "date" },
              endDate: { bsonType: "date" },
              totalCost: { bsonType: "number" },
              status: { 
                bsonType: "string",
                enum: ["pending", "active", "completed", "cancelled"]
              }
            }
          }
        }
      }
    }
  }
});