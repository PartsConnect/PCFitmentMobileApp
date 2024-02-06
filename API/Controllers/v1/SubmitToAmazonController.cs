using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using System.Net;
using TestRestAPI.Models.Utilities;
using Microsoft.AspNetCore.Authorization;
using PCFitment_API.IService;
using System.Security.Cryptography;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System;
using PartsConnectWebTools.Data;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class SubmitToAmazonController : ControllerBase
    {
        private readonly SubmitToAmazonService _submitToAmazonService;
        private readonly GeneralService _generalService;

        public SubmitToAmazonController(SubmitToAmazonService submitToAmazonService, GeneralService generalService)
        {
            _submitToAmazonService = submitToAmazonService;
            _generalService = generalService;
        }

        [Authorize]
        [HttpGet("GetBrandsForAmazon")]
        public IActionResult GetBrandsForAmazon([FromQuery] string tenantID)
        {
            IEnumerable<MDLBrandCode> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLBrandCode>)_generalService.GetBrands(Convert.ToInt32(tenantID));

                if (data.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetHeaderDetailsForAmazon")]
        public IActionResult GetHeaderDetailsForAmazon([FromQuery] string tenantID)
        {
            TenantsHeaderDetail data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (TenantsHeaderDetail)_submitToAmazonService.GetHeaderDetailsForAmazon(Convert.ToInt32(tenantID));

                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpPost("SubmitToAmazon")]
        public IActionResult SubmitToAmazon(TenantsHeaderDetail tenantsHeaderDetail)
        {
            IActionResult response = Unauthorized();
            string msg = "";
            try
            {
                msg = _submitToAmazonService.SubmitToAmazon(tenantsHeaderDetail);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = msg });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

        [Authorize]
        [HttpPost("submitToAmazonVerification")]
        public IActionResult submitToAmazonVerification(TenantsHeaderDetail tenantsHeaderDetail)
        {
            IActionResult response = Unauthorized();
            string msg = "";
            try
            {
                msg = _submitToAmazonService.submitToAmazonVerification(tenantsHeaderDetail);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = msg });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

    }
}
