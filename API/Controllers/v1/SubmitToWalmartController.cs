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
    public class SubmitToWalmartController : ControllerBase
    {
        private readonly SubmitToWalmartService _submitToWalmartService;
        private readonly GeneralService _generalService;

        public SubmitToWalmartController(SubmitToWalmartService submitToWalmartService, GeneralService generalService)
        {
            _submitToWalmartService = submitToWalmartService;
            _generalService = generalService;
        }

        [Authorize]
        [HttpGet("GetBrandsForWalmart")]
        public IActionResult GetBrands([FromQuery] string tenantID)
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
        [HttpGet("GetHeaderDetailsForWalmart")]
        public IActionResult GetHeaderDetailsForWalmart([FromQuery] string tenantID)
        {
            TenantsHeaderDetail data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (TenantsHeaderDetail)_submitToWalmartService.GetHeaderDetailsForWalmart(Convert.ToInt32(tenantID));

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
        [HttpPost("SubmitToWalmart")]
        public IActionResult SubmitToWalmart(TenantsHeaderDetail tenantsHeaderDetail)
        {
            IActionResult response = Unauthorized();
            string msg = "";
            try
            {
                msg = _submitToWalmartService.SubmitToWalmart(tenantsHeaderDetail);

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
