import { useEffect } from "react";
import { useUserStore } from "../../stores/useUserStore";
import { Link, useLocation } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import { Button } from "../../components/elements/Button/Button";
import "./login.css";

export const Login = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const successMessage = location.state?.message;

    // Destructures the function loginUser and some other states from the useUserStore hook
    const { loginUser, username, setUsername, password, setPassword, errorMessage, setErrorMessage } = useUserStore();

    useEffect(() => {
        setErrorMessage("");
        setUsername("");
        setPassword("");
    }, []);

    // Function to handle the login using the loginUser function from the useUserStore hook
    const handleLogin = async (event) => {
        event.preventDefault();

        try {
            await loginUser(username, password);
            const loggedInValue = localStorage.getItem("isLoggedIn");
            const isLoggedIn = loggedInValue === "true";
            // If the user is logged in, the accessToken will be saved in localStorage and the user will be redirected to the dashboard

            // If the user gets logged in, the user will be redirected to the dashboard, otherwise an error message will be displayed
            if (isLoggedIn) {
                navigate("/dashboard");
                setErrorMessage("");
                return;
            } else {
                setUsername(username);
                setPassword(password);
                errorMessage;
            }
        } catch (error) {
            console.error("There was an error =>", error);
        }
    }

    // Function to handle the removal of the errormessage when the user clicks on the register link
    const handleClearOnNavigate = () => {
        setErrorMessage("");
    }

    return (
        <>
            <h1>Welcome back! Let&apos;s log in!</h1>
            <form className="form-wrapper">
                <div className="form-group">
                    <label htmlFor="username">Username</label>
                    <input
                        type="text"
                        id="username"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        required />
                </div>
                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required />
                </div>
                {successMessage && <p className="disclaimer" style={{ color: "green" }}>{successMessage}</p>}
                <p className="error-message disclaimer">{errorMessage}</p>
                <Button className={"primary"} handleOnClick={handleLogin} btnText={"Login"} />
                <div className="light-pair-text">
                    <p className="disclaimer">First time here?</p>
                    <p className="disclaimer"><Link onClick={handleClearOnNavigate} className="disclaimer bold" to="/register">Register</Link> for an account!</p>
                </div>
            </form>
        </>
    )
}
