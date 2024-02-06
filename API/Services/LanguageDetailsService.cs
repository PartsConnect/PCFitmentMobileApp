using Dapper;
using Microsoft.Extensions.Configuration.UserSecrets;
using Microsoft.IdentityModel.Tokens;
using PartsConnectWebTools.Helpers;
using PCFitment_API.IService;
using PCFitment_API.Models;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Numerics;
using System.Reflection.PortableExecutable;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.Arm;
using System.Text;
using TestRestAPI.Models.Utilities;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace PCFitment_API.Services
{
    public class LanguageDetailsService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();

        //----------------* Language List *---------------------//

        public object GetLanguages()
        {
            IEnumerable<MDLGetLanguages> mDLGetLanguages;
            StringBuilder stbSqlQuery = new StringBuilder();
            using (SqlConnection connection = new SqlConnection(clsConnection.CommonConnString()))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT * FROM [dbo].[App_Languages] ");
                mDLGetLanguages = connection.Query<MDLGetLanguages>(stbSqlQuery.ToString(), null, null, true, 100000).ToList();

                connection.Close();
            }

            return mDLGetLanguages;
        }

        //----------------* Language Wise Labels List *---------------------//

        public object GetLanguageWiseLabels(string LanguageCode)
        {
            IEnumerable<MDLGetLanguageWiseLabels> mDLGetLanguageWiseLabels;
            StringBuilder stbSqlQuery = new StringBuilder();
            using (SqlConnection connection = new SqlConnection(clsConnection.CommonConnString()))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" EXEC [dbo].[SP_LanguageLabels] ");

                if (!string.IsNullOrEmpty(LanguageCode))
                {
                    stbSqlQuery.Append(@" '" + LanguageCode + "' ");
                }

                mDLGetLanguageWiseLabels = connection.Query<MDLGetLanguageWiseLabels>(stbSqlQuery.ToString(), null, null, true, 100000).ToList();

                connection.Close();
            }

            return mDLGetLanguageWiseLabels;
        }

        public object GetLangAndTermcndAndPrivacyplc(string LanguageCode, string DeviceID)
        {
            MDLGetLangAndTermcndAndPrivacyplc mDLGetLangAndTermcndAndPrivacyplcs = new MDLGetLangAndTermcndAndPrivacyplc();
            StringBuilder stbSqlQuery = new StringBuilder();
            using (SqlConnection connection = new SqlConnection(clsConnection.CommonConnString()))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" EXEC [dbo].[SP_LanguageLabels] ");

                if (!string.IsNullOrEmpty(LanguageCode))
                {
                    stbSqlQuery.Append(@" '" + LanguageCode + "' ");
                }

                mDLGetLangAndTermcndAndPrivacyplcs.LanguageWiseLabels = connection.Query<MDLGetLanguageWiseLabels>(stbSqlQuery.ToString(), null, null, true, 100000).ToList();

                connection.Close();
            }

            MDLGetTermsAndConditionAndPrivacyPolicy getTCAndPP = new MDLGetTermsAndConditionAndPrivacyPolicy();
            getTCAndPP.IsTermsAndConditionAccept = Convert.ToString(commonMethods.IsTermsAndConditionAccept(DeviceID, false));
            getTCAndPP.IsPrivacyPolicyAccept = Convert.ToString(commonMethods.IsPrivacyPolicyAccept(DeviceID, false));
            getTCAndPP.TermsAndConditionLink = commonMethods.GetTermsAndConditionUrl();
            getTCAndPP.PrivacyPolicyLink = commonMethods.GetPrivacyAndPolicyUrl();

            mDLGetLangAndTermcndAndPrivacyplcs.TermsAndConditionAndPrivacyPolicies = getTCAndPP;

            return mDLGetLangAndTermcndAndPrivacyplcs;
        }

    }
}
