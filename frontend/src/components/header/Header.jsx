import { useEffect, useState } from "react";
import { elastic as Menu } from "react-burger-menu"; // Import the Menu component
import { useNavigate, Link } from "react-router-dom";
import { Button } from "../elements/Button/Button";
import { useUserStore } from "../../stores/useUserStore";
import { useGiftStore } from "../../stores/useGiftStore";
import "./header.css";
import hamburgerIcon from "../../assets/hamburger.svg";
import crossIcon from "../../assets/cross.svg";
import beeImage from "../../assets/bee.svg";
import honeyImage from "../../assets/honey.svg";
import { SearchBar } from "../elements/Search/SearchBar";

// Component for the header
export const Header = () => {
    const { logoutUser, isLoggedIn } = useUserStore();
    const { hives, getHives } = useGiftStore();
    // State to control whether the menu is open or closed
    const [menuOpen, setMenuOpen] = useState(false);
    const navigate = useNavigate();

    // Fetches the hives if the user is logged in
    useEffect(() => {
        if (isLoggedIn) {
            getHives();
        }
    }, [getHives, isLoggedIn]);

    // Function to handle the logout using the logoutUser function from the useUserStore hook
    const handleLogout = async () => {
        try {
            await logoutUser();
            setMenuOpen(false); // Closes the menu after logout
            navigate("/"); // Navigates to the home page after logout
            console.clear(); // Clears the console after the logout
        } catch (error) {
            console.error("There was an error during logout =>", error);
        }
    }

    // Function to close the menu when the user clicks on a link
    const closeMenu = () => {
        setMenuOpen(false);
    }

    return (
        <header className="site-header">
            <div className="logo">
                {isLoggedIn ?
                    <Link to="/dashboard">
                        <img src={beeImage} alt="Gifthive Logo" />
                    </Link> :
                    <Link to="/login">
                        <img src={beeImage} alt="Gifthive Logo" />
                    </Link>
                }

            </div>
            <div className="search-and-menu">
                <SearchBar />
                {/* Configures the React Burger Menu */}
                <Menu
                    right
                    pageWrapId=""
                    outerContainerId=""
                    isOpen={menuOpen}
                    onStateChange={(state) => setMenuOpen(state.isOpen)}
                    closeMenuOnBlur={true}
                    customBurgerIcon={<img src={hamburgerIcon} alt="Hamburger menu icon" />}
                    customCrossIcon={<img className="custom-icon" src={crossIcon} alt="Close menu icon" />}
                    className={"mobile-nav"}
                    width={"300px"}
                >
                    <main id="page-wrap">
                        <img className="honey-image" src={honeyImage} alt="Image of honey dripping down the menu" />

                        {isLoggedIn ? (
                            <>
                                <ul className="main-list" onClick={closeMenu}>
                                    <li><Link to="/dashboard" className="main-list-link">Dashboard</Link></li>
                                    <li><Link to="/hives" className="main-list-link">All hives</Link>
                                        <ul className="minor-list">
                                            {hives.map((hive) => {
                                                return (
                                                    <li key={hive._id}>
                                                        <Link to={`/hives/${hive._id}`}>{hive.name}</Link>
                                                    </li>
                                                )
                                            })}
                                        </ul>
                                    </li>
                                    <li><Link to="/shared-hives" className="main-list-link">Shared hives</Link></li>
                                    <li><Link to="/faq" className="main-list-link">FAQ</Link></li>
                                    <li><Link to="/account" className="main-list-link">Account</Link></li>
                                </ul>

                                <Button className="primary" btnText="Log out" handleOnClick={handleLogout} />
                            </>
                        ) : (
                            <ul className="main-list">
                                <li><Link to="/login">Login</Link></li>
                                <li><Link to="/register">Register</Link></li>
                            </ul>
                        )}

                    </main>
                </Menu>
            </div>
        </header >
    )
}
