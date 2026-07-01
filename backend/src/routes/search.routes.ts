// backend/src/routes/search.routes.ts
import { Router } from "express";
import { SearchController } from "../controllers/search.controller";
import { authenticate } from "../middleware/auth.middleware";

const router = Router();
const searchController = new SearchController();

// ============================================
// MAIN SEARCH ENDPOINTS (Public)
// ============================================

/**
 * @route   GET /api/search
 * @desc    Unified search - searches courses, instructors, and categories
 * @access  Public
 * @query   q - Search query (required)
 * @query   type - 'all' | 'courses' | 'instructors' | 'categories' (default: 'all')
 * @query   page - Page number (default: 1)
 * @query   limit - Items per page (default: 20)
 * @query   category - Filter by category ID
 * @query   level - 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED'
 * @query   price - 'free' | 'paid'
 * @query   sortBy - 'relevance' | 'rating' | 'students' | 'newest'
 */
router.get("/", searchController.unifiedSearch);

/**
 * @route   GET /api/search/trending
 * @desc    Get trending courses, instructors, and categories
 * @access  Public
 */
router.get("/trending", searchController.getTrending);

/**
 * @route   GET /api/search/suggestions
 * @desc    Get autocomplete suggestions for search
 * @access  Public
 * @query   q - Search query (minimum 2 characters)
 */
router.get("/suggestions", searchController.getSuggestions);

// ============================================
// TYPE-SPECIFIC SEARCH (Public)
// ============================================

/**
 * @route   GET /api/search/courses
 * @desc    Search courses only
 * @access  Public
 * @query   q - Search query (required)
 * @query   category - Filter by category ID
 * @query   level - 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED'
 * @query   price - 'free' | 'paid'
 * @query   sortBy - 'relevance' | 'rating' | 'students' | 'newest'
 * @query   page - Page number (default: 1)
 * @query   limit - Items per page (default: 20)
 */
router.get("/courses", searchController.searchByType);

/**
 * @route   GET /api/search/instructors
 * @desc    Search instructors only
 * @access  Public
 * @query   q - Search query (required)
 * @query   page - Page number (default: 1)
 * @query   limit - Items per page (default: 20)
 */
router.get("/instructors", searchController.searchByType);

/**
 * @route   GET /api/search/categories
 * @desc    Search categories only
 * @access  Public
 * @query   q - Search query (required)
 * @query   page - Page number (default: 1)
 * @query   limit - Items per page (default: 20)
 */
router.get("/categories", searchController.searchByType);

// ============================================
// RECENT SEARCHES (Protected - Requires Auth)
// ============================================

/**
 * @route   GET /api/search/recent
 * @desc    Get user's recent searches
 * @access  Private (requires authentication)
 * @header  Authorization: Bearer {token}
 */
router.get("/recent", authenticate, searchController.getRecentSearches);

/**
 * @route   POST /api/search/recent
 * @desc    Save a recent search for the user
 * @access  Private (requires authentication)
 * @header  Authorization: Bearer {token}
 * @body    { "query": "search term" }
 */
router.post("/recent", authenticate, searchController.saveRecentSearch);

/**
 * @route   DELETE /api/search/recent
 * @desc    Clear all recent searches for the user
 * @access  Private (requires authentication)
 * @header  Authorization: Bearer {token}
 */
router.delete("/recent", authenticate, searchController.clearRecentSearches);

export default router;