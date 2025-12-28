const { JsonWebTokenError, TokenExpiredError } = require('jsonwebtoken');

/**
 * Global error handler middleware
 * Must be placed after all routes in app.js
 */
const errorHandler = (err, req, res, next) => {
    console.error('Error caught by global handler:', err);

    // Default error response
    let statusCode = err.statusCode || 500;
    let response = {
        success: false,
        message: 'Internal server error',
        error: 'ServerError'
    };

    // Sequelize Unique Constraint Error
    if (err.name === 'SequelizeUniqueConstraintError') {
        statusCode = 400;
        const field = err.errors?.[0]?.path || 'field';
        const value = err.errors?.[0]?.value || '';
        response = {
            success: false,
            message: `${field} '${value}' already exists`,
            error: 'UniqueConstraintError'
        };
    }

    // Sequelize Validation Error
    else if (err.name === 'SequelizeValidationError') {
        statusCode = 400;
        const messages = err.errors?.map(e => e.message).join(', ') || 'Validation failed';
        response = {
            success: false,
            message: messages,
            error: 'ValidationError'
        };
    }

    // Sequelize Foreign Key Constraint Error
    else if (err.name === 'SequelizeForeignKeyConstraintError') {
        statusCode = 400;
        response = {
            success: false,
            message: 'Foreign key constraint violation. Referenced record does not exist or is in use.',
            error: 'ForeignKeyConstraintError'
        };
    }

    // Sequelize Database Error
    else if (err.name === 'SequelizeDatabaseError') {
        statusCode = 500;
        response = {
            success: false,
            message: 'Database error occurred',
            error: 'DatabaseError'
        };
    }

    // JWT Token Expired Error
    else if (err instanceof TokenExpiredError) {
        statusCode = 401;
        response = {
            success: false,
            message: 'Token has expired',
            error: 'TokenExpiredError'
        };
    }

    // JWT Invalid Token Error
    else if (err instanceof JsonWebTokenError) {
        statusCode = 401;
        response = {
            success: false,
            message: 'Invalid token',
            error: 'JsonWebTokenError'
        };
    }

    // Custom Application Errors (with statusCode and message)
    else if (err.statusCode && err.message) {
        statusCode = err.statusCode;
        response = {
            success: false,
            message: err.message,
            error: err.name || 'ApplicationError'
        };
    }

    // Generic Error
    else if (err.message) {
        response.message = err.message;
        response.error = err.name || 'Error';
    }

    // Include error details in development mode
    if (process.env.NODE_ENV === 'development') {
        response.details = {
            stack: err.stack,
            name: err.name,
            original: err
        };
    }

    return res.status(statusCode).json(response);
};

/**
 * 404 Not Found handler
 * Place this before the error handler in app.js
 */
const notFoundHandler = (req, res, next) => {
    const error = new Error(`Route not found: ${req.method} ${req.originalUrl}`);
    error.statusCode = 404;
    error.name = 'NotFoundError';
    next(error);
};

/**
 * Async error wrapper
 * Wraps async route handlers to catch errors and pass to error handler
 */
const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

module.exports = {
    errorHandler,
    notFoundHandler,
    asyncHandler
};
