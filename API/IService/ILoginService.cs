using PCFitment_API.Models;

namespace PCFitment_API.IService
{
    public interface ILoginService
    {
        string AuthenticateTenant(Login tenant);
    }
}
