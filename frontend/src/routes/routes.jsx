import { Route } from "react-router-dom";
import { Home } from "../pages/home/Home";
import { Login } from "../pages/login/Login";
import { ForgotPassword } from "../pages/forgotPassword/ForgotPassword";
import { ResetPassword } from "../pages/resetPassword/ResetPassword";
import { Register } from "../pages/register/Register";
import { Dashboard } from "../pages/dashboard/Dashboard";
import { Hives } from "../pages/hives/Hives";
import { UniqueHive } from "../pages/hives/UniqueHive";
import { CreateNewHive } from "../pages/create/CreateNewHive";
import { CreateNewGift } from "../pages/create/CreateNewGift";
import { Faq } from "../pages/faq/Faq";
import { ErrorPage } from "../pages/errorPage/ErrorPage";
import { Account } from "../pages/account/Account";
import { UpdateGiftInfo } from "../pages/create/UpdateGiftInfo";
import { SharedHives } from "../pages/hives/SharedHives";
import { UpdateSharedGiftInfo } from "../pages/create/UpdateSharedGiftInfo";

// Creates the routes for the application
const routes = (
    <>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/reset-password" element={<ResetPassword />} />
        <Route path="/register" element={<Register />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/hives" element={<Hives />} />
        <Route path="/hives/:id" element={<UniqueHive />} />
        <Route path="/add-hive" element={<CreateNewHive />} />
        <Route path="/hives/:id/add-gift" element={<CreateNewGift />} />
        <Route path="/account" element={<Account />} />
        <Route path="/shared-hives" element={<SharedHives />} />
        <Route path="/hives/:id/:giftId/update-gift" element={<UpdateGiftInfo />} />
        <Route path="/hives/:id/:giftId/update-shared-gift" element={<UpdateSharedGiftInfo />} />
        <Route path="/faq" element={<Faq />} />
        <Route path="*" element={<ErrorPage />} />
    </>
);

export default routes
