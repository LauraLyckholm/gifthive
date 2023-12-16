import { Route } from "react-router-dom";
import { Home } from "../pages/home/Home";
import { Login } from "../pages/login/Login";
import { Register } from "../pages/register/Register";
import { UniqueHive } from "../pages/hives/UniqueHive";
import { CreateHive } from "../pages/hives/CreateHive";
import { AllHives } from "../pages/hives/AllHives";
import { Faq } from "../pages/faq/Faq";
import { ErrorPage } from "../pages/errorPage/ErrorPage";

const routes = (
    <>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/hives" element={<AllHives />} />
        <Route path="/create-hive" element={<CreateHive />} />
        <Route path="/hives/:id" element={<UniqueHive />} />
        <Route path="/faq" element={<Faq />} />
        <Route path="*" element={<ErrorPage />} />
    </>
);

export default routes