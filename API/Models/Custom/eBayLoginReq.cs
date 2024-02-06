using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public class eBayLoginReq
    {
       /// ID TenantID    reqfrom reqstatus   reqDate
        public int ID { get; set; }
        public int TenantID { get; set; }
        public string reqfrom { get; set; }
        public string reqstatus { get; set; }
        public DateTime reqDate { get; set; }
    }
}