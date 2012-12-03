using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AnteUp.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.Message = "AnteUp, the simple expense tracker between roommates.";

            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "If you're reading this, you shouldn't be.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Contact page.";

            return View();
        }
    }
}
