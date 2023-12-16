import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Button } from "../../components/elements/Button/Button";
import { useGiftStore } from "../../stores/useGiftStore";
import { useUserStore } from "../../stores/useUserStore";

export const AllHives = () => {
    const { hives, getHives, deleteHive } = useGiftStore();
    const { accessToken, isLoggedIn, username } = useUserStore();
    const [loggedInUser, setLoggedInUser] = useState("");

    useEffect(() => {
        getHives();
        setLoggedInUser(localStorage.getItem("username"));
    }, [hives, accessToken, getHives, username, isLoggedIn])

    const handleDelete = async (hiveId) => {

        try {
            await deleteHive(hiveId);
            getHives();
        } catch (error) {
            console.error("There was an error =>", error);
        }
    };

    return (
        <>
            {isLoggedIn ? (
                <div className="dashboard">
                    <h1>{`Welcome to your Gifthive ${loggedInUser}`}!</h1>
                    {hives.length === 0 ? (
                        <div>
                            <p>Looks like there aren’t any hives here right now.. Get started by creating one!</p>
                            <Link to="/create-hive"><Button className={"primary"} btnText={"Start a new hive"} /></Link>
                        </div>
                    ) : (
                        <>
                            <h2>Your hives:</h2>
                            <ul>
                                {hives.map((hive) => {
                                    return (
                                        <li className="list-item-pair" key={hive._id}>
                                            <Link to={`/hives/${hive._id}`}><p>{hive.name}</p></Link>
                                            <p onClick={() => handleDelete(hive._id)}>Delete</p>
                                        </li>

                                    )
                                })}
                            </ul>
                        </>
                    )}
                </div>
            ) : (
                <div className="dashboard">
                    <p>You need to log in to see the content</p>
                    <Link to="/login"><Button className="primary" btnText="Log in" /></Link>
                </div>
            )}
        </>
    )
}