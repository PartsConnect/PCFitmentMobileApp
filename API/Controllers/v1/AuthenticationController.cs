using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using System.Security.Claims;
using System.Net;
using TestRestAPI.Models.Utilities;
using PCFitment_API.IService;
using System.Net.Mail;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class AuthenticationController : ControllerBase
    {
        private readonly LoginService _loginService;
        private readonly IConfiguration _configuration;
        public Int64 expirationTimeInMinutes = 0;
        public string DefaultConnection = "";

        public AuthenticationController(IConfiguration configuration, LoginService loginService)
        {
            _loginService = loginService;
            _configuration = configuration;
            expirationTimeInMinutes = _configuration.GetValue<Int64>("AppSettings:ExpirationTimeInMinutes");
        }

        private string GenrateToken(Login tenant, int mstrtenantID)
        {
            var jwt = _configuration.GetSection("Jwt").Get<Jwt>();
            var claim = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub,jwt.subject),
                new Claim(JwtRegisteredClaimNames.Jti,Guid.NewGuid().ToString()),
                new Claim(JwtRegisteredClaimNames.Iat,DateTime.UtcNow.ToString()),
                new Claim("mstrtenantID",mstrtenantID.ToString()),
                new Claim("Email" ,tenant.Email),
                new Claim("Password",tenant.Password)
            };
            var securitykey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.key));
            var credentials = new SigningCredentials(securitykey, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                jwt.Issuer, jwt.Audience, claim,
            expires: DateTime.Now.AddMinutes(expirationTimeInMinutes),
            signingCredentials: credentials
            );
            string Token = new JwtSecurityTokenHandler().WriteToken(token);
            return Token;
        }

        [AllowAnonymous]
        [HttpPost("Authentication")]
        public IActionResult GetAuthToken(Login tenant)
        {
            IActionResult response = Unauthorized();
            try
            {
                string[] data = AuthenticateTenant(tenant);
                int mstrtenantID = Convert.ToInt32(data[0]);
                string mstrtenantName = Convert.ToString(data[1]);
                var ExpirationTime = expirationTimeInMinutes;
                int RecordId = 0;
                if (mstrtenantID > 0)
                {
                    var token = GenrateToken(tenant, Convert.ToInt32(mstrtenantID));
                    if (!string.IsNullOrEmpty(tenant.FCMToken) && !string.IsNullOrEmpty(tenant.DeviceID))
                    {
                        RecordId = _loginService.SaveFCMToken(mstrtenantID, tenant.FCMToken, tenant.DeviceID, tenant.IsTermsAndConditionAccept, tenant.IsPrivacyPolicyAccept);
                        if (RecordId <= 0)
                        {
                            tenant.FCMToken = string.Empty;
                        }
                        response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Login_Success, data = new { token = token, Id = mstrtenantID, TenantName = mstrtenantName, Email = tenant.Email, tenant.FCMToken, ExpirationTime } });
                    }
                    else
                    {
                        response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = "parameter is missing", data = new { tenant.FCMToken, tenant.DeviceID } });
                    }
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_Login_Invalid, data = new { } });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data = new { } });
            }

            return response;
        }

        private string[] AuthenticateTenant(Login tenant)
        {
            string AcceptResult = "";
            string[]? AcceptResultArr = null;
            if (tenant != null)
            {
                AcceptResult = _loginService.AuthenticateTenant(tenant);
                if (!string.IsNullOrEmpty(AcceptResult))
                {
                    AcceptResultArr = AcceptResult.Split('~');
                }
            }

            return AcceptResultArr;
        }
    }
}
