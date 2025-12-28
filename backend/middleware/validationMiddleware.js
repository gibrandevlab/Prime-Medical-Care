const { body, validationResult } = require('express-validator');
const { Pasien, Poli, Dokter, User } = require('../models');

/**
 * Middleware to handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            error: 'ValidationError',
            details: errors.array()
        });
    }
    next();
};

/**
 * Validation schema for Pasien
 */
const validatePasien = [
    body('nik')
        .trim()
        .notEmpty().withMessage('NIK is required')
        .isLength({ min: 16, max: 16 }).withMessage('NIK must be exactly 16 characters')
        .isNumeric().withMessage('NIK must contain only numbers')
        .custom(async (value, { req }) => {
            // Check for duplicate NIK (skip if updating same record)
            const existing = await Pasien.findOne({ where: { nik: value } });
            if (existing && existing.id !== parseInt(req.params.id)) {
                throw new Error('NIK already exists');
            }
            return true;
        }),

    body('nama')
        .trim()
        .notEmpty().withMessage('Nama is required')
        .isLength({ min: 2, max: 255 }).withMessage('Nama must be between 2 and 255 characters'),

    body('email')
        .optional({ checkFalsy: true })
        .trim()
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail()
        .custom(async (value, { req }) => {
            if (!value) return true; // Skip if empty (optional field)
            // Check for duplicate email in USERS table
            const existingUser = await User.findOne({ where: { email: value } });
            if (existingUser) {
                // If updating, check if this email belongs to the user associated with this patient
                if (req.params.id) {
                    const currentPasien = await Pasien.findByPk(req.params.id);
                    if (currentPasien && currentPasien.userId === existingUser.id) {
                        return true; // Email belongs to current user/pasien
                    }
                }
                throw new Error('Email already exists');
            }
            return true;
        }),

    body('nomor_telepon')
        .optional({ checkFalsy: true })
        .trim()
        .matches(/^[0-9+\-\s()]+$/).withMessage('Invalid phone number format'),

    body('alamat')
        .optional({ checkFalsy: true })
        .trim()
        .isLength({ max: 500 }).withMessage('Alamat must not exceed 500 characters'),

    body('tanggal_lahir')
        .optional({ checkFalsy: true })
        .isDate().withMessage('Invalid date format for tanggal_lahir'),

    body('password')
        .optional({ checkFalsy: true })
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),

    handleValidationErrors
];

/**
 * Validation schema for Antrian
 */
const validateAntrian = [
    body('pasienId')
        .notEmpty().withMessage('pasienId is required')
        .isInt({ min: 1 }).withMessage('pasienId must be a valid integer')
        .custom(async (value) => {
            const pasien = await Pasien.findByPk(value);
            if (!pasien) {
                throw new Error('Pasien not found');
            }
            return true;
        }),

    body('poliId')
        .notEmpty().withMessage('poliId is required')
        .isInt({ min: 1 }).withMessage('poliId must be a valid integer')
        .custom(async (value) => {
            const poli = await Poli.findByPk(value);
            if (!poli) {
                throw new Error('Poli not found');
            }
            return true;
        }),

    body('dokterId')
        .optional({ checkFalsy: true })
        .isInt({ min: 1 }).withMessage('dokterId must be a valid integer')
        .custom(async (value) => {
            if (!value) return true;
            const dokter = await Dokter.findByPk(value);
            if (!dokter) {
                throw new Error('Dokter not found');
            }
            return true;
        }),

    body('scheduledAt')
        .optional({ checkFalsy: true })
        .isISO8601().withMessage('Invalid date format for scheduledAt')
        .custom((value) => {
            if (!value) return true;
            const scheduledDate = new Date(value);
            const now = new Date();
            if (scheduledDate < now) {
                throw new Error('scheduledAt must be in the future');
            }
            return true;
        }),

    handleValidationErrors
];

/**
 * Validation schema for Poli
 */
const validatePoli = [
    body('nama_poli')
        .trim()
        .notEmpty().withMessage('nama_poli is required')
        .isLength({ min: 2, max: 255 }).withMessage('nama_poli must be between 2 and 255 characters'),

    body('keterangan')
        .optional({ checkFalsy: true })
        .trim()
        .isLength({ max: 1000 }).withMessage('keterangan must not exceed 1000 characters'),

    handleValidationErrors
];

/**
 * Validation schema for Dokter
 */
const validateDokter = [
    body('nama')
        .trim()
        .notEmpty().withMessage('nama is required')
        .isLength({ min: 2, max: 255 }).withMessage('nama must be between 2 and 255 characters'),

    body('nip')
        .optional({ checkFalsy: true })
        .trim()
        .isLength({ max: 50 }).withMessage('nip must not exceed 50 characters'),

    body('poliId')
        .notEmpty().withMessage('poliId is required')
        .isInt({ min: 1 }).withMessage('poliId must be a valid integer')
        .custom(async (value) => {
            const poli = await Poli.findByPk(value);
            if (!poli) {
                throw new Error('Poli not found');
            }
            return true;
        }),

    body('email')
        .optional({ checkFalsy: true })
        .trim()
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail(),

    body('nomor_telepon')
        .optional({ checkFalsy: true })
        .trim()
        .matches(/^[0-9+\-\s()]+$/).withMessage('Invalid phone number format'),

    body('password')
        .optional({ checkFalsy: true })
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),

    handleValidationErrors
];

/**
 * Validation schema for Pegawai
 */
const validatePegawai = [
    body('nama')
        .trim()
        .notEmpty().withMessage('nama is required')
        .isLength({ min: 2, max: 255 }).withMessage('nama must be between 2 and 255 characters'),

    body('nip')
        .trim()
        .notEmpty().withMessage('nip is required')
        .isLength({ max: 50 }).withMessage('nip must not exceed 50 characters'),

    body('role')
        .optional({ checkFalsy: true })
        .isIn(['admin', 'petugas']).withMessage('role must be either admin or petugas'),

    body('email')
        .optional({ checkFalsy: true })
        .trim()
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail(),

    body('nomor_telepon')
        .optional({ checkFalsy: true })
        .trim()
        .matches(/^[0-9+\-\s()]+$/).withMessage('Invalid phone number format'),

    body('tanggal_lahir')
        .optional({ checkFalsy: true })
        .isDate().withMessage('Invalid date format for tanggal_lahir'),

    body('password')
        .optional({ checkFalsy: true })
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),

    handleValidationErrors
];

module.exports = {
    validatePasien,
    validateAntrian,
    validatePoli,
    validateDokter,
    validatePegawai,
    handleValidationErrors
};
