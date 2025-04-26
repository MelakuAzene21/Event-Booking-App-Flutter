const axios = require('axios');
const dotenv = require('dotenv');
const booking = require('../models/Booking');
dotenv.config();
// Determine the base URL based on the environment
const baseUrl = process.env.NODE_ENV === 'production'
    ? 'https://e-market-hbf7.onrender.com'
    : 'http://localhost:3000';

exports.InializePayment = async (req, res) => {
    try {
        const { amount, currency, email, firstName, lastName, tx_ref } = req.body;

        if (!email || !email.includes('@')) {
            return res.status(400).json({ message: 'Invalid email format' });
        }

        const paymentData = {
            amount,
            currency,
            email,
            first_name: firstName,
            last_name: lastName,
            tx_ref,
            // callback_url: 'http://localhost:5000/payment/callback',
            callback_url: `https://3508-213-55-102-49.ngrok-free.app/payment/callback?tx_ref=${tx_ref}`,
            return_url: `${baseUrl}/success?tx_ref=${tx_ref}`, // Dynamically set return_url
            customization: {
                "title": "Ticket Booking"

            }
        };

        const chapaResponse = await axios({
            method: 'post',
            url: 'https://api.chapa.co/v1/transaction/initialize',
            headers: {
                Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`,
                'Content-Type': 'application/json'
            },
            data: paymentData
        });
        // res.json(chapaResponse.data)
        return res.status(200).json({ payment_url: chapaResponse.data.data.checkout_url });
    } catch (error) {
        console.error('Error initializing payment:', error.response ? error.response.data : error.message);
        res.status(500).json({
            message: 'Error initializing payment',
            error: error.response ? error.response.data : error.message
        });
    }
}

exports.verifyTransaction = async (req, res) => {
    try {
        const txRef = req.params.tx_ref; // Get tx_ref from the route parameter
        const url = `https://api.chapa.co/v1/transaction/verify/${txRef}`;

        // Make a request to verify the transaction with Chapa API
        const response = await axios.get(url, {
            headers: {
                Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`
            }
        });

        if (response.status === 200 && response.data.status === 'success') {
            const { tx_ref, status } = response.data.data;

            // Check if the payment status is "success"
            if (status === 'success' && tx_ref) {
                // Find the order in the database using the tx_ref
                const book = await booking.findOne({ tx_ref: tx_ref });
                console.log('Booking data by tx refs from verifying', book);

                // Check if the order exists and its payment status is "pending"
                if (book && book.status && book.status === 'pending') {
                    // Update the status status to "booked"
                    book.status = 'booked';

                    await book.save();
                    console.log("booking ID want for QR code", book._id);

                    // Send a response indicating the book was successfully updated
                    return res.status(200).json({
                        success: true,
                        message: 'Transaction verified and book payment status updated successfully.',
                        bookingId: book._id,
                        book
                    });
                } else if (!book) {
                    console.error('booking', book);
                    return res.status(404).json({
                        success: false,
                        message: 'book not found'
                    });
                } else if (book.status !== 'pending') {
                    return res.status(200).json({
                        success: true,
                        message: 'Payment already processed for this Booking.',
                        bookingId: book._id,
                        book
                    });
                }
            }
        }

        // If the transaction verification failed, return an error
        res.status(400).json({
            success: false,
            message: 'Transaction verification failed or invalid transaction reference.'
        });
    } catch (error) {
        console.error('Error verifying transaction:', error);
        res.status(500).json({
            success: false,
            message: 'Error verifying transaction',
            error: error.response ? error.response.data : error.message
        });
    }
};