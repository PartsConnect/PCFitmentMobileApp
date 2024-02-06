using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using System.Net;
using TestRestAPI.Models.Utilities;
using Microsoft.AspNetCore.Authorization;
using PCFitment_API.IService;
using System.Security.Cryptography;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System.Linq;
using System.Security.Claims;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class MyPartsAndFitmentController : ControllerBase
    {
        private readonly MyPartsAndFitmentService _myPartsAndFitmentService;

        public MyPartsAndFitmentController(MyPartsAndFitmentService myPartsAndFitmentService)
        {
            _myPartsAndFitmentService = myPartsAndFitmentService;
        }
        
        [Authorize]
        [HttpGet("GetMyPartsAndFitment")]
        public IActionResult GetMyPartsAndFitment([FromQuery] PARMyPartsAndFitment pARMy)
        {
            MDLGetMyPartsAndFitmentInfo data = null;
            int IMPageSize = commonMethods.PageSize();
            int IMpageNumber = string.IsNullOrEmpty(pARMy.pageNumber) ? 1 : int.Parse(pARMy.pageNumber);
            int totalRecords = 0, totalPages = 0;
            string ReceivedtenantID = string.IsNullOrEmpty(pARMy.tenantID) ? "0" : pARMy.tenantID;
            IActionResult response = Unauthorized();
            try
            {
                data = (MDLGetMyPartsAndFitmentInfo)_myPartsAndFitmentService.GetMyPartsAndFitmentList(Convert.ToInt32(ReceivedtenantID), Convert.ToInt32(pARMy.ddlItemId), pARMy.searchValue, IMPageSize, IMpageNumber, false);

                totalRecords = (int)_myPartsAndFitmentService.GetMyPartsAndFitmentList(Convert.ToInt32(ReceivedtenantID),Convert.ToInt32(pARMy.ddlItemId), pARMy.searchValue, IMPageSize, IMpageNumber, true);
                totalPages = (int)Math.Ceiling(totalRecords / (decimal)IMPageSize);

                if (data != null && data.MyPartsAndFitmentList.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Pagesize = IMPageSize, CurrentPage = IMpageNumber, totalRecords = totalRecords, totalPages = totalPages, Message = Messages.CON_Success, data });
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
        [HttpGet("GetSavedFitments")]
        public IActionResult GetSavedFitments([FromQuery] PARSavedAndErrorFitment pARMy1)
        {
            IEnumerable<MDLGetSavedFitments> data = null;
            string ReceivedtenantID = string.IsNullOrEmpty(pARMy1.tenantID) ? "0" : pARMy1.tenantID;
            int IMPageSize = commonMethods.PageSize();
            int IMpageNumber = string.IsNullOrEmpty(pARMy1.pageNumber) ? 1 : int.Parse(pARMy1.pageNumber);
            int totalRecords = 0, totalPages = 0;

            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetSavedFitments>)_myPartsAndFitmentService.GetSavedFitments(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, false, Convert.ToInt32(pARMy1.partID), pARMy1.YearSearch, pARMy1.MakeSearch, pARMy1.ModelSearch);

                totalRecords = (int)_myPartsAndFitmentService.GetSavedFitments(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, true, Convert.ToInt32(pARMy1.partID), pARMy1.YearSearch, pARMy1.MakeSearch, pARMy1.ModelSearch);
                totalPages = (int)Math.Ceiling(totalRecords / (decimal)IMPageSize);

                if (data.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Pagesize = IMPageSize, CurrentPage = IMpageNumber, totalRecords = totalRecords, totalPages = totalPages, Message = Messages.CON_Success, data });
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
        [HttpGet("GetErrorFitments")]
        public IActionResult GetErrorFitments([FromQuery] PARSavedAndErrorFitment pARMy2)
        {
            IEnumerable<MDLGetErrorFitments> data = null;
            string ReceivedtenantID = string.IsNullOrEmpty(pARMy2.tenantID) ? "0" : pARMy2.tenantID;
            int IMPageSize = commonMethods.PageSize();
            int IMpageNumber = string.IsNullOrEmpty(pARMy2.pageNumber) ? 1 : int.Parse(pARMy2.pageNumber);
            int totalRecords = 0, totalPages = 0;

            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetErrorFitments>)_myPartsAndFitmentService.GetErrorFitments(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, false, Convert.ToInt32(pARMy2.partID), pARMy2.YearSearch, pARMy2.MakeSearch, pARMy2.ModelSearch);
                totalRecords = (int)_myPartsAndFitmentService.GetErrorFitments(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, true, Convert.ToInt32(pARMy2.partID),pARMy2.YearSearch, pARMy2.MakeSearch, pARMy2.ModelSearch);
                totalPages = (int)Math.Ceiling(totalRecords / (decimal)IMPageSize);

                if (data.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Pagesize = IMPageSize, CurrentPage = IMpageNumber, totalRecords = totalRecords, totalPages = totalPages, Message = Messages.CON_Success, data });
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
        
    }
}
