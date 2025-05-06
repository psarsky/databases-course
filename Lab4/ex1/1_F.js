// 1. Oryginalne kolekcje:
let maxOrderID = db.orders.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID;

db.orderdetails.updateMany(
  { OrderID: maxOrderID },
  [
    {
      $set: {
        Discount: { $round: [{ $add: ["$Discount", 0.05] }, 2] }
      }
    }
  ]
);


// 2. OrdersInfo:
let maxOrderID = db.OrdersInfo.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID;

db.OrdersInfo.updateOne(
  { OrderID: maxOrderID },
  [
    {
      $set: {
        Orderdetails: {
          $map: {
            input: "$Orderdetails",
            as: "detail",
            in: {
              UnitPrice: "$$detail.UnitPrice",
              Quantity: "$$detail.Quantity",
              Discount: { $round: [{ $add: ["$$detail.Discount", 0.05] }, 2] },
              Value: {
                $round: [
                  {
                    $multiply: [
                      "$$detail.UnitPrice",
                      "$$detail.Quantity",
                      { $subtract: [1, { $add: ["$$detail.Discount", 0.05] }] }
                    ]
                  },
                  2
                ]
              },
              product: "$$detail.product"
            }
          }
        }
      }
    },
    {
      $set: {
        OrderTotal: { $sum: "$Orderdetails.Value" }
      }
    }
  ]
);


// 3. CustomerInfo:
let maxOrderID = db.orders.find().sort({OrderID: -1}).limit(1).toArray()[0].OrderID + 1;

db.CustomerInfo.updateOne(
  { "Orders.OrderID": maxOrderID },
  [
    {
      $set: {
        Orders: {
          $map: {
            input: "$Orders",
            as: "order",
            in: {
              $cond: [
                { $eq: ["$$order.OrderID", maxOrderID] },
                {
                  OrderID: "$$order.OrderID",
                  Employee: "$$order.Employee",
                  Dates: "$$order.Dates",
                  Orderdetails: {
                    $map: {
                      input: "$$order.Orderdetails",
                      as: "detail",
                      in: {
                        UnitPrice: "$$detail.UnitPrice",
                        Quantity: "$$detail.Quantity",
                        Discount: { $round: [{ $add: ["$$detail.Discount", 0.05] }, 2] },
                        Value: {
                          $round: [
                            {
                              $multiply: [
                                "$$detail.UnitPrice",
                                "$$detail.Quantity",
                                { $subtract: [1, { $add: ["$$detail.Discount", 0.05] }] }
                              ]
                            },
                            2
                          ]
                        },
                        product: "$$detail.product"
                      }
                    }
                  },
                  Freight: "$$order.Freight",
                  OrderTotal: {
                    $sum: {
                      $map: {
                        input: "$$order.Orderdetails",
                        as: "detail",
                        in: {
                          $round: [
                            {
                              $multiply: [
                                "$$detail.UnitPrice",
                                "$$detail.Quantity",
                                { $subtract: [1, { $add: ["$$detail.Discount", 0.05] }] }
                              ]
                            },
                            2
                          ]
                        }
                      }
                    }
                  },
                  Shipment: "$$order.Shipment"
                },
                "$$order"
              ]
            }
          }
        }
      }
    }
  ]
);
