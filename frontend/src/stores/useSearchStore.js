import { create } from "zustand";

// Gets the url to the API from the env file
const API_URL = import.meta.env.VITE_BACKEND_API;
// Saves the endpoint in a variable for easy access
const withEndpoint = (endpoint) => `${API_URL}/search-routes/search?${endpoint}`;

// Creates a store for the user handling
export const useSearchStore = create((set) => ({
    searchTerm: "",
    searchData: [],
    searchPerformed: false,

    setSearchTerm: (searchTerm) => { set({ searchTerm }) },
    setSearchPerformed: (searchPerformed) => { set({ searchPerformed }) },

    searchItems: async (searchValue) => {
        try {
            const response = await fetch(withEndpoint(`searchTerm=${searchValue}`), {
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            if (response.status === 404) {
                set({
                    searchData: [],
                    searchPerformed: true,
                });
            } else

                if (response.ok) {
                    const data = await response.json();
                    set({
                        searchData: data,
                        searchPerformed: true,
                    });
                }
        } catch (error) {
            console.error("There was an error =>", error);
        }
    },

    // Function to search hives by ID
    searchHivesById: async (hiveId) => {
        // Join the IDs into a comma-separated string or similar

        try {
            const response = await fetch(withEndpoint(`searchTerm=${hiveId}`), {
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            if (response.ok) {
                const data = await response.json();
                set({
                    searchData: data,
                    searchPerformed: true,
                });
            } else {
                console.error("Error searching hives");
            }
        } catch (error) {
            console.error("There was an error =>", error);
        }
    },
}));