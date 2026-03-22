import mongoose, { Schema } from "mongoose";

const PasswordResetTokenSchema = new Schema({
    userId: {
        type: mongoose.SchemaTypes.ObjectId,
        ref: "User",
        required: true,
    },
    token: {
        type: String,
        required: true,
    },
    expiresAt: {
        type: Date,
        required: true,
    },
});

export const PasswordResetToken = mongoose.model("PasswordResetToken", PasswordResetTokenSchema);
