import { Router } from 'express';
import { AuthService } from '../services/authService';
import { validateRequest, schemas } from '../middleware/validation';
import { authenticateToken } from '../middleware/auth';
import { ApiResponse } from '../types';

const router = Router();

// Register new user
router.post('/register', validateRequest(schemas.createUser), async (req, res) => {
  try {
    const authResponse = await AuthService.register(req.body);
    
    const response: ApiResponse = {
      success: true,
      data: authResponse,
      message: 'User registered successfully'
    };

    res.status(201).json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Registration failed'
    };

    res.status(400).json(response);
  }
});

// Login user
router.post('/login', validateRequest(schemas.login), async (req, res) => {
  try {
    const authResponse = await AuthService.login(req.body);
    
    const response: ApiResponse = {
      success: true,
      data: authResponse,
      message: 'Login successful'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Login failed'
    };

    res.status(401).json(response);
  }
});

// Refresh access token
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      const response: ApiResponse = {
        success: false,
        error: 'Refresh token required'
      };
      res.status(400).json(response);
      return;
    }

    const { accessToken } = await AuthService.refreshToken(refreshToken);
    
    const response: ApiResponse = {
      success: true,
      data: { accessToken },
      message: 'Token refreshed successfully'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Token refresh failed'
    };

    res.status(401).json(response);
  }
});

// Change password
router.post('/change-password', authenticateToken, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user!.id;

    if (!currentPassword || !newPassword) {
      const response: ApiResponse = {
        success: false,
        error: 'Current password and new password are required'
      };
      res.status(400).json(response);
      return;
    }

    await AuthService.changePassword(userId, currentPassword, newPassword);
    
    const response: ApiResponse = {
      success: true,
      message: 'Password changed successfully'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Password change failed'
    };

    res.status(400).json(response);
  }
});

// Request password reset
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      const response: ApiResponse = {
        success: false,
        error: 'Email is required'
      };
      res.status(400).json(response);
      return;
    }

    await AuthService.resetPassword(email);
    
    const response: ApiResponse = {
      success: true,
      message: 'If the email exists, a password reset link has been sent'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Password reset request failed'
    };

    res.status(500).json(response);
  }
});

// Get current user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const response: ApiResponse = {
      success: true,
      data: req.user,
      message: 'Profile retrieved successfully'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to retrieve profile'
    };

    res.status(500).json(response);
  }
});

// Logout (client-side token removal)
router.post('/logout', authenticateToken, async (req, res) => {
  try {
    const response: ApiResponse = {
      success: true,
      message: 'Logout successful'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Logout failed'
    };

    res.status(500).json(response);
  }
});

export default router;
