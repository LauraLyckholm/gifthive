import { create } from "zustand";

// Gets the url to the API from the env file
const API_URL = import.meta.env.VITE_BACKEND_API;
// Saves the endpoint in a variable for easy access
const withEndpoint = (endpoint) => `${API_URL}/user-routes/${endpoint}`;

// Creates a store for the user handling
export const useUserStore = create((set, get) => ({

    // Saves some state variables in the store with default values
    username: "",
    password: "",
    accessToken: null,
    isLoggedIn: false,
    loading: false,
    errorMessage: "",
    userId: "",

    // Sets the values of the state variables to the values being passed in
    setUsername: (username) => set({ username }),
    setPassword: (password) => set({ password }),
    setAccessToken: (accessToken) => set({ accessToken }),
    setIsLoggedIn: (isLoggedIn) => set({ isLoggedIn: isLoggedIn }),
    setLoading: (loading) => set({ loading: loading }),
    setErrorMessage: (errorMessage) => set({ errorMessage: errorMessage }),
    setUserId: (userId) => set({ userId: userId }),

    // Creates a function for registering a user
    registerUser: async (username, password) => {
        // Checks if the username or password is empty, and if so, alerts the user and returns
        if (!username || !password) {
            set({ errorMessage: "Please enter both username and password" });
            return;
        }

        try {
            set({ loading: true });

            const response = await fetch(withEndpoint("register"), {
                method: "POST", // Uses the POST method
                headers: {
                    "Content-Type": "application/json",
                },
                // Sends the username and password in the body of the request
                body: JSON.stringify({
                    username,
                    password,
                }),
            });

            // If the response is not ok, throw an error
            if (!response.ok) {
                const data = await response.json();
                set({
                    loading: false,
                    errorMessage: "Registration failed, please try again"
                })
                if (data.error) {
                    if (data.error.includes("unique")) {
                        set({ errorMessage: "Username already exists. Please choose another one." });
                    } else {
                        set({ errorMessage: data.error });
                    }
                }
                throw new Error(`${response.status} ${response.statusText}`);
            }

            // If the response is ok, saves the response as a variable called data
            const data = await response.json();
            const successfullFetch = data.success;

            // In case of a successfull fetch, sets the state variables to the values from the response
            if (successfullFetch) {
                set({
                    username: username,
                    loading: false
                })
            }

            // Alerts to the user that the username has been registered
            alert(successfullFetch ? `The user ${data.response.username} has been created` : `The username ${data.response.username} couldn't be registered`);

            set({
                password: "" // Sets the password to empty, indicating to the user that they can now try logging in
            })

        } catch (error) {
            // If the error message is 400, the username already exists, so an alert is shown and the fields are emptied

            set({
                username: "",
                password: "",
                loading: false,
                errorMessage: "Username already exists, please choose another one"
            })

            console.error("There was an error =>", error);

        }
    },

    // Creates a function for logging in a user
    loginUser: async (username, password, userId) => {
        // Checks if the username or password is empty, and if so, alerts the user and returns
        if (!username || !password) {
            set({ errorMessage: "Please enter both username and password" });
            return;
        }

        try {
            set({ loading: true });

            const response = await fetch(withEndpoint("login"), {
                method: "POST", // Uses the POST method
                headers: {
                    "Content-Type": "application/json",
                },
                // Sends the username and password in the body of the request
                body: JSON.stringify({
                    username,
                    password,
                    userId
                }),
            });

            // If the response is not ok, throw an error
            if (!response.ok) {
                set({ loading: false });

                if (response.status === 401) {
                    // Unauthorized error (Wrong username or password)
                    set({ errorMessage: "Wrong username or password, please try again" });
                } else if (response.status === 404) {
                    // User not found error (Username not found)
                    set({ errorMessage: "Username not found, please try again" });
                } else {
                    // Other HTTP errors
                    set({ errorMessage: "Something went wrong, please try again" });
                }

                throw new Error(`${response.status} ${response.statusText}`);
            }

            // If the response is ok, saves the response as a variable called data
            const data = await response.json();
            const successfullFetch = data.success;

            // In case of a successfull fetch, sets the state variables to the values from the response
            if (successfullFetch) {
                set({
                    username: username,
                    accessToken: data.response.accessToken,
                    isLoggedIn: true,
                    userId: data.response._id,
                })
                // Saves the accessToken in localStorage
                localStorage.setItem("accessToken", data.response.accessToken);
                localStorage.setItem("username", username);
                localStorage.setItem("userId", data.response._id);

            } else {
                set({
                    username: "",
                    accessToken: null,
                    isLoggedIn: false,
                    loading: false,
                    errorMessage: "Login failed, please try again"
                });
            }

            // Logs a response to the console
            console.log(data.response.username, get().isLoggedIn ? "is logged in" : "is not logged in");

        } catch (error) {
            if (error.message == 401) {
                set({
                    username: "",
                    password: "",
                    loading: false,
                    errorMessage: "Wrong username or password, please try again"
                })
            } else if (error.message == 404) {
                set({
                    username: "",
                    password: "",
                    loading: false,
                    errorMessage: "Username not found, please try again"
                })
            }
            console.error("There was an error =>", error);
        }
    },

    logoutUser: () => {
        // Removes the accessToken from the store and sets isLoggedIn to false. Also empties the username and password fields
        set({
            username: "",
            password: "",
            accessToken: null,
            isLoggedIn: false,
            userId: "",
        });
        // Removes the accessToken from localStorage
        localStorage.clear();
    },

    // Function to check if there's a stored token in localStorage, to allow for refresh of secret page
    initAuth: () => {
        const storedToken = localStorage.getItem("accessToken");

        if (storedToken) {
            set({
                accessToken: storedToken,
                isLoggedIn: true,
            });
        }
    },
}));

// Initialize authentication when the store is created
const userStore = useUserStore.getState();
userStore.initAuth();

export default userStore;