using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{
    public class Login
    {
        public string Email { get; set; }
        public string Password { get; set; }
        public string FCMToken { get; set; } = string.Empty;
        public string DeviceID { get; set; } = string.Empty;
        public string IsTermsAndConditionAccept { get; set; } = string.Empty;
        public string IsPrivacyPolicyAccept { get; set; } = string.Empty;
    }
    public class Jwt
    {
        public string key { get; set; }
        public string Issuer { get; set; }
        public string Audience { get; set; }
        public string subject { get; set; }
    }
}
