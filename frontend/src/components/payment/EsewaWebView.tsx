import React, { useRef, useState, useEffect } from 'react';
import {
  View,
  ActivityIndicator,
  TouchableOpacity,
  Text,
  StyleSheet,
  SafeAreaView,
  Alert,
  Platform,
} from 'react-native';
import { WebView, WebViewNavigation } from 'react-native-webview';

// ─────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────

interface EsewaWebViewProps {
  payload: Record<string, string>;
  esewaUrl: string;
  onSuccess: (courseId: string, paymentId: string) => void;
  onFailure: (reason: string) => void;
  onClose: () => void;
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

/**
 * Builds an HTML page that auto-submits a POST form to eSewa
 * on load. This is the only way to send a form POST from a
 * WebView — fetch() can't do cross-origin form POSTs.
 */
function buildEsewaFormHtml(
  payload: Record<string, string>,
  esewaUrl: string
): string {
  const hiddenInputs = Object.entries(payload)
    .map(
      ([key, value]) =>
        `<input type="hidden" name="${key}" value="${value}" />`
    )
    .join('\n');

  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
          body {
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background: #f5f5f5;
            font-family: sans-serif;
          }
          .loader {
            text-align: center;
            color: #666;
          }
          .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #e0e0e0;
            border-top-color: #60BB46;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 16px;
          }
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        </style>
      </head>
      <body>
        <div class="loader">
          <div class="spinner"></div>
          <p>Redirecting to eSewa...</p>
        </div>

        <form id="esewaForm" action="${esewaUrl}" method="POST">
          ${hiddenInputs}
        </form>

        <script>
          // Auto-submit immediately on page load
          window.onload = function() {
            document.getElementById('esewaForm').submit();
          };
        </script>
      </body>
    </html>
  `;
}

/**
 * Extracts a query param value from a URL string.
 */
function getQueryParam(url: string, param: string): string | null {
  try {
    const urlObj = new URL(url);
    return urlObj.searchParams.get(param);
  } catch {
    // URL parsing can fail on deep link schemes like exp://
    const regex = new RegExp(`[?&]${param}=([^&]*)`);
    const match = url.match(regex);
    return match ? decodeURIComponent(match[1]) : null;
  }
}

/**
 * Checks if URL is a success/failure redirect from our backend OR eSewa
 */
function analyzeUrl(url: string): { 
  isSuccess: boolean; 
  isFailure: boolean; 
  courseId: string; 
  paymentId: string; 
  reason: string;
  hasEsewaData: boolean;
} {
  const courseId = getQueryParam(url, 'courseId') ?? '';
  const paymentId = getQueryParam(url, 'paymentId') ?? '';
  const reason = getQueryParam(url, 'reason') ?? 'payment_failed';
  const hasEsewaData = url.includes('data=');
  
  // Our backend redirect URLs
  const backendSuccess = url.includes('/payment/success') || url.includes('payment/success');
  const backendFailure = url.includes('/payment/failure') || url.includes('payment/failure');
  
  // eSewa's own redirect URLs
  const esewaSuccess = url.includes('esewa.com.np/epay/success') || 
                       url.includes('esewa.com.np/epay/result') ||
                       url.includes('epay/main/v2/success');
  const esewaFailure = url.includes('esewa.com.np/epay/failure') || 
                       url.includes('esewa.com.np/epay/cancel') ||
                       url.includes('epay/main/v2/failure');
  
  // Deep link schemes
  const deepLink = url.startsWith('buildakar://') || url.startsWith('exp://');
  
  const isSuccess = backendSuccess || esewaSuccess || (deepLink && !!courseId && (url.includes('success') || hasEsewaData));
  const isFailure = backendFailure || esewaFailure || (deepLink && (url.includes('failure') || url.includes('cancel') || url.includes('error')));
  
  return { isSuccess, isFailure, courseId, paymentId, reason, hasEsewaData };
}

// ─────────────────────────────────────────────
// COMPONENT
// ─────────────────────────────────────────────

export default function EsewaWebView({
  payload,
  esewaUrl,
  onSuccess,
  onFailure,
  onClose,
}: EsewaWebViewProps) {
  const webViewRef = useRef<WebView>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasHandledRedirect, setHasHandledRedirect] = useState(false);
  const [currentUrl, setCurrentUrl] = useState('');

  const formHtml = buildEsewaFormHtml(payload, esewaUrl);

  /**
   * Monitors every URL navigation the WebView makes.
   * When it detects our backend's success/failure redirect,
   * it extracts the params and calls the appropriate callback.
   */
  function handleNavigationStateChange(navState: WebViewNavigation) {
    const { url } = navState;
    
    if (!url) return;
    
    setCurrentUrl(url);

    // Prevent handling the same redirect multiple times
    if (hasHandledRedirect) return;

    console.log('🌐 [EsewaWebView] Navigation:', url);

    const { isSuccess, isFailure, courseId, paymentId, reason, hasEsewaData } = analyzeUrl(url);

    // ─── Success ───────────────────────────────
    if (isSuccess && courseId) {
      setHasHandledRedirect(true);
      console.log('✅ [EsewaWebView] Payment success detected', { courseId, paymentId, url });
      
      setTimeout(() => {
        onSuccess(courseId, paymentId);
      }, 100);
      return;
    }

    // ─── Failure ───────────────────────────────
    if (isFailure) {
      setHasHandledRedirect(true);
      console.log('❌ [EsewaWebView] Payment failure detected', { reason, url });
      
      setTimeout(() => {
        onFailure(reason);
      }, 100);
      return;
    }

    // ─── Log all other navigations for debugging ─────
    console.log('🌐 [EsewaWebView] Intermediate navigation:', url);
  }

  function handleLoadStart() {
    setIsLoading(true);
  }

  function handleLoadEnd() {
    setIsLoading(false);
  }

  function handleError(e: any) {
    console.error('❌ [EsewaWebView] Error:', e.nativeEvent);
    if (!hasHandledRedirect) {
      onFailure('webview_error');
    }
  }

  function handleClose() {
    if (hasHandledRedirect) return;

    Alert.alert(
      'Cancel Payment',
      'Are you sure you want to cancel this payment?',
      [
        { text: 'Continue Payment', style: 'cancel' },
        {
          text: 'Cancel',
          style: 'destructive',
          onPress: onClose,
        },
      ]
    );
  }

  // For web platform, also listen for messages from popup
  useEffect(() => {
    if (Platform.OS !== 'web') return;

    const handleMessage = (event: MessageEvent) => {
      if (hasHandledRedirect) return;
      
      try {
        const data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
        if (data.type === 'ESEWA_SUCCESS' && data.courseId) {
          setHasHandledRedirect(true);
          onSuccess(data.courseId, data.paymentId);
        } else if (data.type === 'ESEWA_FAILURE') {
          setHasHandledRedirect(true);
          onFailure(data.reason || 'payment_failed');
        }
      } catch {
        // Ignore parse errors
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, [hasHandledRedirect, onSuccess, onFailure]);

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          onPress={handleClose}
          style={styles.closeButton}
          hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
        >
          <Text style={styles.closeText}>✕</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Pay with eSewa</Text>
        <View style={styles.closeButton} />
      </View>

      {/* WebView */}
      <View style={styles.webViewContainer}>
        <WebView
          ref={webViewRef}
          source={{ html: formHtml }}
          onNavigationStateChange={handleNavigationStateChange}
          onLoadStart={handleLoadStart}
          onLoadEnd={handleLoadEnd}
          onError={handleError}
          javaScriptEnabled
          domStorageEnabled
          startInLoadingState
          // Allow navigation to eSewa domains
          originWhitelist={['*']}
          // Show native loading bar on iOS
          showsVerticalScrollIndicator={false}
          // iOS specific
          allowsInlineMediaPlayback={true}
          mediaPlaybackRequiresUserAction={false}
          // Android specific
          mixedContentMode="always"
          thirdPartyCookiesEnabled={true}
          userAgent={`BuildakarAcademy/1.0 (${Platform.OS}) AppleWebKit/537.36`}
        />

        {/* Loading overlay */}
        {isLoading && (
          <View style={styles.loadingOverlay}>
            <ActivityIndicator size="large" color="#60BB46" />
            <Text style={styles.loadingText}>Loading eSewa...</Text>
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}

// ─────────────────────────────────────────────
// STYLES
// ─────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
    backgroundColor: '#fff',
  },
  headerTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
  },
  closeButton: {
    width: 32,
    height: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeText: {
    fontSize: 18,
    color: '#666',
  },
  webViewContainer: {
    flex: 1,
    position: 'relative',
  },
  loadingOverlay: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
  },
  loadingText: {
    fontSize: 14,
    color: '#666',
    marginTop: 8,
  },
});