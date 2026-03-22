// ------------ IMPORTS ------------ //
import { User } from "../models/User"
import asyncHandler from "express-async-handler";
import bcrypt from "bcrypt";
import { Hive } from "../models/Hive";
import { Gift } from "../models/Gift";
import { PasswordResetToken } from "../models/PasswordResetToken";
import crypto from "crypto";
import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY);

// ------------ CONTROLLERS ------------ //
// Register a user
export const registerUserController = asyncHandler(async (req, res) => {
    const { username, password, email } = req.body;

    const lowerCaseUsername = username.toLowerCase();

    try {
        // Check if the user already exists in the database, by finding a user with the same username from the database
        const usernameExists = await User.findOne({ username: { $regex: new RegExp("^" + lowerCaseUsername + "$", "i") } });
        const emailExists = await User.findOne({ email });


        // If the user exists, send an error to the client, saying the user already exists
        if (usernameExists) {
            return res.status(400).json({
                success: false,
                response: "User with the username " + username + " already exists"
            });
        } else if (emailExists) {
            return res.status(400).json({
                success: false,
                response: "User with the email " + email + " already exists"
            });
        }

        // Validate that all required fields are filled in
        if (!username || !password || !email) {
            res.status(400).json({
                success: false,
                response: {
                    message: "Please fill in all required fields",
                }
            });
        };

        // Validate that the email added is an actual email
        if (!/.+\@.+\..+/.test(email)) {
            return res.status(400).json({
                success: false,
                validationSuccess: false,
                response: {
                    message: "Please enter a valid email address",
                }
            });
        }

        // Validate password
        if (password.length < 7 || !/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/.test(password)) {
            return res.status(400).json({
                success: false,
                validationSuccess: false,
                response: {
                    message: "Password must be at least 7 characters long, include uppercase and lowercase letters and least one number."
                }
            });
        }

        // Validate username
        if (username.length < 5 || username.length > 20) {
            return res.status(400).json({
                success: false,
                validationSuccess: false,
                response: {
                    message: "Username must be between 5 and 20 characters long."
                }
            });
        }

        // Encrypts the password, so that no plain text passwords are stored in the database
        const hashedPassword = bcrypt.hashSync(password, 10);

        // If all checks pass, create a new user with the username and hashed version of the users password
        const newUser = new User({
            username,
            email,
            password: hashedPassword,
        });

        // Saves the user to the database
        await newUser.save();

        // Sends a response to the client, containing the user's username, id, and a JWT token.
        res.status(201).json({
            success: true,
            response: {
                username: newUser.username,
                email: newUser.email,
                id: newUser._id,
                accessToken: newUser.accessToken
            },
        });

    } // If an error occurs, send an errormessage to the client
    catch (err) {
        if (err.code === 11000) {
            return res.status(400).json({
                success: false,
                response: {
                    message: "Username already exists. Please choose another username.",
                    errors: err
                }
            });
        } else {
            // Handle other errors
            return res.status(400).json({
                success: false,
                response: {
                    message: "Could not create user",
                    errors: err
                }
            });
        }
    }
});

// Creates a controller function for the route that is used to log in a user
export const loginUserController = asyncHandler(async (req, res) => {
    const { username, password } = req.body;
    const user = await User.findOne({ username });

    try {
        // First check if there is no user with that name, then ask the user to register
        if (!user) {
            return res.status(404).json({
                success: false,
                response: "User not found, please register for an account"
            })
        }

        // Then check if the password is correct, if not, return an error
        const passwordMatch = await bcrypt.compare(password, user.password);
        if (!passwordMatch) {
            return res.status(401).json({
                success: false,
                response: "Incorrect password"
            })
            // If the password is correct, return the user's informations
        } else {
            return res.status(201).json({
                success: true,
                response: {
                    _id: user._id,
                    username: user.username,
                    accessToken: user.accessToken,
                    hives: user.hives,
                    gifts: user.gifts,
                    email: user.email,
                }
            })
        }
    } catch (err) {
        { // Checks against the rules in the model, if any of them are broken, it will return an error
            res.status(400).json({
                success: false,
                response: {
                    message: "Could not log in user",
                    errors: err.errors
                }
            })
        }
    }
});

// Creates a controller function for the route that is used to get the dashboard, which is only accessible if the user is logged in. The authentication is done in the routes-file
export const getDashboardController = asyncHandler(async (req, res) => {
    const { username, hives, gifts, sharedHives } = req.user; // gets the username from the authenticated user
    try {
        // Returns the necessary information to the client
        res.json({
            message: `Welcome to your Dashboard, ${username}!`,
            hivesCount: hives.length,
            giftsCount: gifts.length,
            gifts: gifts,
            hives: hives,
            sharedHives: sharedHives
        });

        // If an error occurs, send an errormessage to the client
    } catch (err) {
        res.status(400).json({
            success: false,
            response: {
                errors: err.errors
            }
        })
    }
});

// Creates a controller function for the route that is used to get all users - this route is commented out on the userRoutes, as it is only used for testing purposes
// export const getUsersController = asyncHandler(async (req, res) => {
//     try {
//         const users = await User.find();
//         res.status(200).json(users);
//     } catch (error) {
//         res.status(404).json({ message: error.message });
//     }
// });

// Creates a function that makes it possible to update the users information
export const updateUserController = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { username, password, email } = req.body;

    try {
        // Find the user
        const user = await User.findById(id);

        // If no user is found, return an error
        if (!user) {
            return res.status(404).json({ error: "User not found or unauthorized." });
        }

        // Check if a new username is provided and if it's different from the current one
        if (username && username !== user.username) {
            const existingUser = await User.findOne({ username });
            if (existingUser) {
                return res.status(400).json({ error: "Username already exists" });
            }
            user.username = username;
        }

        // Check if the email is provided and if it's different from the current one
        if (email && email !== user.email) {
            const existingEmail = await User.findOne({ email: email.toLowerCase() });
            // If the email already exists, return an error
            if (existingEmail) {
                return res.status(400).json({ error: "Email already exists" });
            }
            user.email = email.toLowerCase();
        }

        // If there is a new password, hash it and save it
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            user.password = hashedPassword;
        }

        // Save the updated user
        await user.save();

        // Return the updated user
        res.json({
            message: "User updated successfully",
            user: {
                _id: user._id,
                username: user.username,
                email: user.email,
            }
        });
        // If an error occurs, send an errormessage to the client
    } catch (error) {
        console.error("Error updating user:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});


// Creates a controller function for deleting a user account
export const deleteUserController = asyncHandler(async (req, res) => {
    const { id } = req.params;

    try {
        // Find the user
        const user = await User.findById(id);

        // If no user is found, return an error
        if (!user) {
            return res.status(404).json({ error: "User not found or unauthorized." });
        }

        // Find all hives shared by the user
        const sharedHives = await Hive.find({ sharedWith: { $in: [user._id] } });
        for (const hive of sharedHives) {
            // Remove the user from the sharedWith array of each hive
            const index = hive.sharedWith.indexOf(user._id);
            if (index > -1) {
                hive.sharedWith.splice(index, 1);
                await hive.save();
            }
        }

        // Delete gifts associated with each of the user's hives
        for (const hive of user.hives) {
            await Gift.deleteMany({ hiveId: hive._id });
        }

        // Delete the user's hives
        await Hive.deleteMany({ userId: user._id });

        // Delete the user
        await User.findByIdAndDelete(id);

        res.json(`User with username ${user.username} deleted successfully`);
        // If an error occurs, send an errormessage to the client
    } catch (error) {
        console.error("Error deleting user:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Sends a password reset email to the user
export const forgotPasswordController = asyncHandler(async (req, res) => {
    const { email } = req.body;

    // Always return 200 so we don't reveal whether an email exists
    const user = await User.findOne({ email: email?.toLowerCase() });
    if (!user) {
        return res.status(200).json({ success: true, response: "If that email is registered, a reset link has been sent." });
    }

    // Delete any existing reset tokens for this user
    await PasswordResetToken.deleteMany({ userId: user._id });

    // Generate a secure random token
    const token = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await new PasswordResetToken({ userId: user._id, token, expiresAt }).save();

    const resetLink = `https://gifthive.netlify.app/reset-password?token=${token}`;

    const { data, error } = await resend.emails.send({
        from: "Gifthive <onboarding@resend.dev>",
        to: user.email,
        subject: "Reset your Gifthive password",
        html: `
            <p>Hi ${user.username},</p>
            <p>We received a request to reset your password. Click the link below to choose a new one:</p>
            <p><a href="${resetLink}" style="color:#FFC440;font-weight:bold;">Reset my password</a></p>
            <p>This link expires in 1 hour. If you didn't request a reset, you can ignore this email.</p>
            <p>— The Gifthive team</p>
        `,
    });

    if (error) {
        console.error("Resend error:", error);
        return res.status(500).json({ success: false, response: error.message });
    }

    console.log("Email sent:", data);
    res.status(200).json({ success: true, response: "If that email is registered, a reset link has been sent." });
});

// Resets the user's password using the token from the email
export const resetPasswordController = asyncHandler(async (req, res) => {
    const { token, password } = req.body;

    if (!token || !password) {
        return res.status(400).json({ success: false, response: "Token and new password are required." });
    }

    // Validate password strength
    if (password.length < 7 || !/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/.test(password)) {
        return res.status(400).json({
            success: false,
            response: "Password must be at least 7 characters and include uppercase, lowercase and a number."
        });
    }

    const resetToken = await PasswordResetToken.findOne({ token });

    if (!resetToken) {
        return res.status(400).json({ success: false, response: "Invalid or expired reset link." });
    }

    if (resetToken.expiresAt < new Date()) {
        await PasswordResetToken.deleteOne({ _id: resetToken._id });
        return res.status(400).json({ success: false, response: "Reset link has expired. Please request a new one." });
    }

    const user = await User.findById(resetToken.userId);
    if (!user) {
        return res.status(404).json({ success: false, response: "User not found." });
    }

    user.password = bcrypt.hashSync(password, 10);
    await user.save();
    await PasswordResetToken.deleteOne({ _id: resetToken._id });

    res.status(200).json({ success: true, response: "Password updated successfully. You can now log in." });
});

// Function to get the users shared hives
export const getUsersSharedHivesController = asyncHandler(async (req, res) => {
    const userId = req.params.id;

    try {
        // Find the user
        const user = await User.findById(userId).populate("sharedHives");

        // Get the users shared hives
        let usersSharedHives = user.sharedHives;

        // if no user is found, return an error
        if (!user) {
            return res.status(404).json({ error: "User not found or unauthorized." });
        }

        // Return the users shared hives
        res.json({
            success: true,
            sharedHives: usersSharedHives
        });
        // If an error occurs, send an errormessage to the client
    } catch (error) {
        console.error("Error getting shared hives:", error);
        res.status(500).json({ error: "Internal server error" });
    };
});