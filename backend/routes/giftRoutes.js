// ------------ IMPORTS ------------ //
import express from "express";
import asyncHandler from "express-async-handler";
import {
    getHivesController,
    getIndividualHiveController,
    createNewController,
    createGiftItemController,
    updateGiftItemController,
    updateHiveName,
    deleteGiftController,
    deleteHiveController
} from "../controllers/giftControllers";
import { authenticateUser } from "../middleware/authenticateUser";
const listEndpoints = require("express-list-endpoints");

// ------------ ROUTES ------------ //
// Creates a new router and makes it available for import in other files
export const giftRouter = express();

// Displays endpoints
giftRouter.get("/", asyncHandler(async (req, res) => {
    try {
        const endpoints = listEndpoints(giftRouter);
        res.json(endpoints);
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: "Something went wrong" });
    }
}));

// ------------ ROUTES ------------ //
giftRouter.get("/hives", authenticateUser, getHivesController);
giftRouter.get("/hives/:id", authenticateUser, getIndividualHiveController);
giftRouter.post("/gifts", authenticateUser, createGiftItemController);
giftRouter.post("/hives", authenticateUser, createNewController);
giftRouter.put("/gifts/:id", authenticateUser, updateGiftItemController);
giftRouter.put("/hives/:id", authenticateUser, updateHiveName);
giftRouter.delete("/gifts/:id", authenticateUser, deleteGiftController);
giftRouter.delete("/hives/:id", authenticateUser, deleteHiveController);