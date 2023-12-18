import { create } from "zustand";
// import { useUserStore } from "./useUserStore";

// Gets the url to the API from the env file
const API_URL = import.meta.env.VITE_BACKEND_API;
// Saves the endpoint in a variable for easy access
const withEndpoint = (endpoint) => `${API_URL}/gift-routes/${endpoint}`;

// Creates a store for the gift hive handling
export const useGiftStore = create((set) => ({
    gift: [],
    hives: [],
    hiveName: "",
    giftName: "",

    setGift: (gift) => set({ gift }),
    setHives: (hives) => set({ hives }),
    setHiveName: (hiveName) => set({ hiveName }),
    setGiftName: (giftName) => set({ giftName }),

    getGifts: async () => {
        try {
            const response = await fetch(withEndpoint("gifts"), {
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            if (response.ok) {
                const data = await response.json();

                set({
                    gift: data
                });
            } else {
                console.error("Error fetching gifts");
            }

        } catch (error) {
            console.error("There was an error =>", error);
        }
    },

    // Function for getting all hives
    getHives: async () => {
        try {
            const response = await fetch(withEndpoint("hives"), {
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            if (response.ok) {
                const data = await response.json();

                set({
                    hives: data
                });
            } else {
                console.error("Error fetching hives");
            }

        } catch (error) {
            console.error("There was an error =>", error);
        }
    },

    // Function for adding a gift
    addGift: async (newGift) => {
        try {
            // Make a POST request to create a new gift
            const response = await fetch(withEndpoint("gifts"), {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Auth": localStorage.getItem("accessToken"),
                },
                body: JSON.stringify(newGift),
            });

            const data = await response.json();

            if (response.ok) {
                set((state) => ({
                    gift: [...state.gift, data]
                }));
            } else {
                console.error("Error adding gift");
            }

        } catch (error) {
            console.error("There was an error =>", error);
        }
    },

    // Function for adding a hive
    addHive: async (newHive) => {
        try {
            // Make a POST request to create a new hive
            const response = await fetch(withEndpoint("hives"), {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Auth": localStorage.getItem("accessToken"),
                },
                body: JSON.stringify(newHive),
            });

            const data = await response.json();

            if (response.ok) {
                set((state) => ({
                    hives: [...state.hives, data],
                }));
            } else {
                console.error("Error adding hive");
            }

        } catch (error) {
            console.error("There was an error =>", error);
        }
    },

    // Function for deleting a gift
    deleteGift: async (giftId) => {
        try {
            // Make a DELETE request to remove a hive
            await fetch(withEndpoint(`gifts/${giftId}`), {
                method: "DELETE",
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            set((state) => ({
                gifts: state.gifts.filter((gift) => gift._id !== giftId),
            }));

        } catch (error) {
            console.error("Error deleting gift:", error);
        }
    },

    // Function for deleting a hive
    deleteHive: async (hiveId) => {
        try {
            // Make a DELETE request to remove a hive
            await fetch(withEndpoint(`hives/${hiveId}`), {
                method: "DELETE",
                headers: {
                    "Auth": localStorage.getItem("accessToken"),
                },
            });

            set((state) => ({
                hives: state.hives.filter((hive) => hive._id !== hiveId),
            }));

        } catch (error) {
            console.error("Error deleting hive:", error);
        }
    },

    // Function for initializing the store
    init: () => {
        const storedGifts = localStorage.getItem("gifts");
        const storedHives = localStorage.getItem("hives");
        const storedUniqueHive = localStorage.getItem("uniqueHive");

        if (storedGifts) set({ gifts: JSON.parse(storedGifts) });
        if (storedHives) set({ hives: JSON.parse(storedHives) });
        if (storedUniqueHive) set({ uniqueHive: JSON.parse(storedUniqueHive) });
    },

    // Method to set state and persist data to local storage
    setAndPersist: (fn) => {
        set(fn);

        // Persist relevant state to local storage after updating
        localStorage.setItem("gifts", JSON.stringify(fn().gifts));
        localStorage.setItem("hives", JSON.stringify(fn().hives));
        localStorage.setItem("uniqueHive", JSON.stringify(fn().uniqueHive));
    },

    // updateGift: async (updatedGift) => {
    //     try {
    //         // Make a PUT request to update an existing gift
    //         const response = await fetch(withEndpoint(`gifts/${updatedGift.id}`), {
    //             method: "PUT",
    //             headers: {
    //                 "Content-Type": "application/json",
    //             },
    //             body: JSON.stringify(updatedGift),
    //         });
    //         const data = await response.json();
    //         set((state) => ({
    //             gifts: state.gifts.map((gift) =>
    //                 gift.id === updatedGift.id ? { ...gift, ...data } : gift
    //             ),
    //         }));
    //     } catch (error) {
    //         console.error("Error updating gift:", error);
    //     }
    // },

    // deleteGift: async (giftId) => {
    //     try {
    //         // Make a DELETE request to remove a gift
    //         await fetch(withEndpoint(`gifts/${giftId}`), {
    //             method: "DELETE",
    //         });
    //         set((state) => ({
    //             gifts: state.gifts.filter((gift) => gift.id !== giftId),
    //         }));
    //     } catch (error) {
    //         console.error("Error deleting gift:", error);
    //     }
    // },

    // setLoading: (isLoading) => {
    //     set({ loading: isLoading });
    // },
}));
