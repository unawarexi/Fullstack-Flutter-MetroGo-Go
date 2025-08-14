// databse connection
import mongoose, { ConnectOptions } from "mongoose";

// Set up default mongoose connection
const connectDB = async (): Promise<void> => {
  try {
    await mongoose.connect(process.env.DB_URI as string, {} as ConnectOptions);
    console.log("MongoDB connected successfully");
  } catch (error) {
    console.error(`MongoDB connection error: ${error}`);
    // Handle the error appropriately (e.g., exit the application)
    process.exit(1);
  }
};

export { connectDB };
