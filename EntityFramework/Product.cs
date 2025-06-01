namespace EntityFramework;

public class Product
{
    public int ProductID { get; set; }
    public string? ProductName { get; set; }
    public int UnitsInStock { get; set; }
    public int? SupplierID { get; set; }
    public Supplier? Supplier { get; set; } = null;
    public List<InvoiceProduct> Invoices { get; set; } = [];
    public override string ToString(){
        if (ProductName == null)
        {
            return "No product name";
        }
        if (Supplier != null && Supplier.CompanyName != null)
        {
            return $"{ProductName} - {UnitsInStock}pcs, Supplier: {Supplier.CompanyName}";
        }
        return $"{ProductName} - {UnitsInStock}pcs";
    }
}