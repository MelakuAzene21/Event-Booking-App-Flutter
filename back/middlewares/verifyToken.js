const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Adjust the path

const verifyToken = async (req, res, next) => {
    try {
        const token = req.cookies.token; // Fetch token from cookies
        console.log('Token received:', token); // Debugging
        if (!token) {
            return res.status(401).json({ message: 'Authentication required' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(401).json({ message: 'User not found' });
        }

        req.user = user; // Attach user to the request
        next();
    } catch (error) {
        console.error('Error in verifyToken:', error.message);
        res.status(401).json({ message: 'Invalid token' });
    }
};

module.exports = verifyToken;
