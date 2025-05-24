using Microsoft.EntityFrameworkCore;
using EntityFramework;

class Program
{
    static void Main()
    {
        var dbContext = new ProdContext();
        bool exit = false;
        
        while (!exit)
        {
            Console.WriteLine("Choose an operation:");
            Console.WriteLine("1. Add a new product with supplier");
            Console.WriteLine("2. Create a new invoice");
            Console.WriteLine("3. Show products for an invoice");
            Console.WriteLine("4. Show invoices for a product");
            Console.WriteLine("5. Exit");
            Console.Write(">>> ");
            
            string? choice = Console.ReadLine();
            
            switch(choice)
            {
                case "1":
                    AddProductWithSupplier(dbContext);
                    break;
                case "2":
                    CreateInvoice(dbContext);
                    break;
                case "3":
                    ShowProductsForInvoice(dbContext);
                    break;
                case "4":
                    ShowInvoicesForProduct(dbContext);
                    break;
                case "5":
                    exit = true;
                    break;
                default:
                    Console.WriteLine("Unknown option");
                    break;
            }
        }
    }
    
    static void AddProductWithSupplier(ProdContext dbContext)
    {
        var newProduct = GetProductDetails();

        bool addedNewSupplier = SupplierSelection(dbContext, out Supplier? selectedSupplier);

        Console.WriteLine("Adding product to supplier...");
        if (selectedSupplier != null)
        {
            selectedSupplier.Products.Add(newProduct);
            newProduct.Supplier = selectedSupplier;
        }

        Console.WriteLine("Saving data...");
        SaveToDatabase(dbContext, newProduct, selectedSupplier, addedNewSupplier);
    }
    
    private static bool SupplierSelection(ProdContext db, out Supplier? selectedSupplier)
    {
        bool createdNew = false;
        
        while (true)
        {
            Console.WriteLine("Do you want to add a new supplier? (y/n; default: n)");
            var response = Console.ReadLine()?.ToLower() ?? "";
            
            if (response == "y")
            {
                selectedSupplier = GetSupplierDetails();
                createdNew = true;
                break;
            }
            else if (response == "n" || response == "")
            {
                ShowSuppliers(db);
                selectedSupplier = SelectExistingSupplier(db);
                break;
            }
        }
        
        return createdNew;
    }
    
    private static void SaveToDatabase(ProdContext db, Product product, Supplier? supplier, bool isNewSupplier)
    {
        if (isNewSupplier && supplier != null)
        {
            db.Suppliers.Add(supplier);
        }
        db.Products.Add(product);
        db.SaveChanges();
    }
    
    private static Product GetProductDetails()
    {
        Console.Write("Enter product name\n>>> ");
        string name = Console.ReadLine() ?? "";
        
        int stock;
        string input;
        do
        {
            Console.Write("Enter number of items in stock\n>>> ");
            input = Console.ReadLine() ?? "";
        } while (string.IsNullOrEmpty(input) || !int.TryParse(input, out stock));
        
        Console.WriteLine("Creating new product...");
        var newProduct = new Product
        {
            ProductName = name,
            UnitsInStock = stock
        };
        
        Console.WriteLine($"Created product: {newProduct}");
        return newProduct;
    }
    
    private static Supplier GetSupplierDetails()
    {
        Console.Write("\nEnter supplier name\n>>> ");
        string name = Console.ReadLine() ?? "";
        
        Console.Write("Enter city name\n>>> ");
        string city = Console.ReadLine() ?? "";
        
        Console.Write("Enter street name\n>>> ");
        string street = Console.ReadLine() ?? "";
        
        Console.WriteLine("Creating new supplier...");
        var newSupplier = new Supplier
        {
            CompanyName = name,
            City = city,
            Street = street
        };
        
        Console.WriteLine($"Created supplier: {newSupplier}");
        return newSupplier;
    }
    
    private static Supplier? SelectExistingSupplier(ProdContext db)
    {
        int supplierId = 0;
        string input;
        
        do
        {
            Console.Write("Enter shipper ID for the new product\n>>> ");
            input = Console.ReadLine() ?? "";
        } while (string.IsNullOrEmpty(input) || !int.TryParse(input, out supplierId));
        
        return db.Suppliers
            .Where(s => s.SupplierID == supplierId)
            .FirstOrDefault();
    }
    
    private static void ShowSuppliers(ProdContext db)
    {
        Console.WriteLine("Supplier list:");
        foreach (var supplier in db.Suppliers)
        {
            Console.WriteLine($"[{supplier.SupplierID}] {supplier}");
        }
    }
    
    private static void CreateInvoice(ProdContext db)
    {
        Console.Write("Enter invoice number\n>>> ");
        string invoiceNumber = Console.ReadLine() ?? "";

        var invoice = new Invoice { InvoiceNumber = invoiceNumber };
        db.Invoices.Add(invoice);
        db.SaveChanges();

        bool addMoreProducts = true;
        while (addMoreProducts)
        {
            Console.WriteLine("\nProduct list:");
            foreach (var product in db.Products)
            {
                Console.WriteLine($"[{product.ProductID}] {product}");
            }

            Console.Write("\nEnter product ID to add to invoice (0 to finish)\n>>> ");
            if (int.TryParse(Console.ReadLine(), out int productId) && productId > 0)
            {
                var product = db.Products.Find(productId);
                if (product != null)
                {
                    Console.Write($"Enter quantity for {product.ProductName}\n>>> ");
                    if (int.TryParse(Console.ReadLine(), out int quantity) && quantity > 0)
                    {
                        var invoiceProduct = new InvoiceProduct
                        {
                            Invoice = invoice,
                            Product = product,
                            Quantity = quantity
                        };
                        
                        invoice.Products.Add(invoiceProduct);
                        product.Invoices.Add(invoiceProduct);
                        
                        db.InvoiceProducts.Add(invoiceProduct);
                        Console.WriteLine($"Added {quantity} of {product.ProductName} to invoice");
                    }
                }
                else
                {
                    Console.WriteLine("Product not found!");
                }
            }
            else
            {
                addMoreProducts = false;
            }
        }
        
        db.SaveChanges();
        Console.WriteLine($"Invoice {invoice.InvoiceNumber} saved with {invoice.Products.Count} products.");
    }
    
    private static void ShowProductsForInvoice(ProdContext db)
    {
        Console.WriteLine("Invoice list:");
        foreach (var invoice in db.Invoices)
        {
            Console.WriteLine($"[{invoice.InvoiceID}] {invoice.InvoiceNumber}");
        }
        Console.Write("\nEnter invoice ID to view products\n>>> ");
        if (int.TryParse(Console.ReadLine(), out int invoiceId))
        {
            var invoice = db.Invoices
                .Include(i => i.Products)
                .ThenInclude(ip => ip.Product)
                .FirstOrDefault(i => i.InvoiceID == invoiceId);
            
            if (invoice != null)
            {
                Console.WriteLine($"\nProducts in invoice {invoice.InvoiceNumber}:");
                foreach (var item in invoice.Products)
                {
                    Console.WriteLine($"- {item.Product?.ProductName}: {item.Quantity} pcs");
                }
            }
            else
            {
                Console.WriteLine("Invoice not found!");
            }
        }
    }
    
    private static void ShowInvoicesForProduct(ProdContext db)
    {
        Console.WriteLine("Product list:");
        foreach (var product in db.Products)
        {
            Console.WriteLine($"[{product.ProductID}] {product.ProductName}");
        }

        Console.Write("\nEnter product ID to view invoices\n>>> ");
        if (int.TryParse(Console.ReadLine(), out int productId))
        {
            var product = db.Products
                .Include(p => p.Invoices)
                .ThenInclude(ip => ip.Invoice)
                .FirstOrDefault(p => p.ProductID == productId);
            
            if (product != null)
            {
                Console.WriteLine($"\nInvoices containing {product.ProductName}:");
                foreach (var item in product.Invoices)
                {
                    Console.WriteLine($"- Invoice {item.Invoice?.InvoiceNumber}: {item.Quantity} pcs");
                }
            }
            else
            {
                Console.WriteLine("Product not found!");
            }
        }
    }
}