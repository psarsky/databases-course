namespace EntityFramework;

public class Supplier : Company
{
    public string? BankAccountNumber { get; set; }
    public List<Product> Products { get; set; } = [];
}
