// DB name
use("skiRentalDBv3");

// Drop existing collections if they exist
db.equipment.drop();
db.clients.drop();
db.reservations.drop();

// Schema for equipment collection
db.createCollection("equipment", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "type", "size", "dailyRate", "isAvailable"],
      properties: {
        name: { bsonType: "string" },
        type: {
          bsonType: "string",
          enum: ["ski", "snowboard", "boots", "poles", "helmet"],
        },
        size: { bsonType: "string" },
        dailyRate: { bsonType: "number", minimum: 0 },
        isAvailable: { bsonType: "bool" },
      },
    },
  },
});

// Schema for clients collection
db.createCollection("clients", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "phone"],
      properties: {
        name: { bsonType: "string" },
        email: { bsonType: "string" },
        phone: { bsonType: "string" },
      },
    },
  },
});

// Schema for hybrid reservations collection
db.createCollection("reservations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "clientId",
        "clientName",
        "equipment",
        "startDate",
        "endDate",
        "totalCost",
        "status",
      ],
      properties: {
        clientId: { bsonType: "objectId" },
        clientName: { bsonType: "string" },
        equipment: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["equipmentId", "name", "type"],
            properties: {
              equipmentId: { bsonType: "objectId" },
              name: { bsonType: "string" },
              type: { bsonType: "string" },
            },
          },
        },
        startDate: { bsonType: "date" },
        endDate: { bsonType: "date" },
        totalCost: { bsonType: "number", minimum: 0 },
        status: {
          bsonType: "string",
          enum: ["pending", "active", "completed", "cancelled"],
        },
      },
    },
  },
});
