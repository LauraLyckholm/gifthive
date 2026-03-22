import { useState } from "react";
import { useSearchParams, useNavigate, Link } from "react-router-dom";
import { Button } from "../../components/elements/Button/Button";
import "./resetPassword.css";

const API_URL = import.meta.env.VITE_BACKEND_API;

export const ResetPassword = () => {
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const token = searchParams.get("token");

    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    if (!token) {
        return (
            <>
                <h1>Invalid link</h1>
                <p className="disclaimer">This reset link is missing or invalid.</p>
                <div className="light-pair-text">
                    <p className="disclaimer"><Link className="disclaimer bold" to="/forgot-password">Request a new one</Link></p>
                </div>
            </>
        );
    }

    const handleSubmit = async (event) => {
        event.preventDefault();
        if (!password || !confirmPassword) {
            setError("Please fill in both fields.");
            return;
        }
        if (password !== confirmPassword) {
            setError("Passwords do not match.");
            return;
        }
        setLoading(true);
        setError("");
        try {
            const response = await fetch(`${API_URL}/user-routes/reset-password`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ token, password }),
            });
            const data = await response.json();
            if (!response.ok) {
                setError(data.response || "Something went wrong. Please try again.");
                return;
            }
            navigate("/login", { state: { message: "Password updated! You can now log in." } });
        } catch {
            setError("Something went wrong. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <>
            <h1>Choose a new password</h1>
            <form className="form-wrapper">
                <div className="form-group">
                    <label htmlFor="password">New password</label>
                    <input
                        type="password"
                        id="password"
                        placeholder="Min 7 chars, upper + lower + number"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="confirmPassword">Confirm new password</label>
                    <input
                        type="password"
                        id="confirmPassword"
                        placeholder="Repeat your new password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        required
                    />
                </div>
                {error && <p className="error-message disclaimer">{error}</p>}
                <Button className={"primary"} handleOnClick={handleSubmit} btnText={loading ? "Saving..." : "Set new password"} />
            </form>
        </>
    );
};
