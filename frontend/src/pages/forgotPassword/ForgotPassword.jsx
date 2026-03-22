import { useState } from "react";
import { Link } from "react-router-dom";
import { Button } from "../../components/elements/Button/Button";
import "./forgotPassword.css";

const API_URL = import.meta.env.VITE_BACKEND_API;

export const ForgotPassword = () => {
    const [email, setEmail] = useState("");
    const [submitted, setSubmitted] = useState(false);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (event) => {
        event.preventDefault();
        if (!email) {
            setError("Please enter your email address.");
            return;
        }
        setLoading(true);
        setError("");
        try {
            await fetch(`${API_URL}/user-routes/forgot-password`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email }),
            });
            setSubmitted(true);
        } catch {
            setError("Something went wrong. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    if (submitted) {
        return (
            <>
                <h1>Check your inbox</h1>
                <p className="disclaimer">
                    If <strong>{email}</strong> is registered, we&apos;ve sent a reset link. It expires in 1 hour.
                </p>
                <div className="light-pair-text">
                    <p className="disclaimer"><Link className="disclaimer bold" to="/login">Back to login</Link></p>
                </div>
            </>
        );
    }

    return (
        <>
            <h1>Forgot your password?</h1>
            <p className="disclaimer">Enter your email and we&apos;ll send you a reset link.</p>
            <form className="form-wrapper">
                <div className="form-group">
                    <label htmlFor="email">Email</label>
                    <input
                        type="email"
                        id="email"
                        placeholder="your@email.com"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                </div>
                {error && <p className="error-message disclaimer">{error}</p>}
                <Button className={"primary"} handleOnClick={handleSubmit} btnText={loading ? "Sending..." : "Send reset link"} />
                <div className="light-pair-text">
                    <p className="disclaimer"><Link className="disclaimer bold" to="/login">Back to login</Link></p>
                </div>
            </form>
        </>
    );
};
