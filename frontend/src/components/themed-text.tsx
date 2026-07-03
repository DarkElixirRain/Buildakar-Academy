import React from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  TextProps,
} from 'react-native';

import { Fonts, ThemeColor } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export type ThemedTextProps = TextProps & {
  type?:
    | 'default'
    | 'title'
    | 'subtitle'
    | 'h1'
    | 'h2'
    | 'h3'
    | 'h4'
    | 'h5'
    | 'h6'
    | 'body'
    | 'caption'
    | 'button'
    | 'small'
    | 'smallBold'
    | 'link'
    | 'linkPrimary'
    | 'code';
  themeColor?: ThemeColor;
};

export function ThemedText({
  style,
  type = 'default',
  themeColor,
  ...rest
}: ThemedTextProps) {
  const theme = useTheme();

  return (
    <Text
      style={[
        {
          color: theme[themeColor ?? 'text'],
        },

        styles.default,

        type === 'title' && styles.title,
        type === 'subtitle' && styles.subtitle,

        type === 'h1' && styles.h1,
        type === 'h2' && styles.h2,
        type === 'h3' && styles.h3,
        type === 'h4' && styles.h4,
        type === 'h5' && styles.h5,
        type === 'h6' && styles.h6,

        type === 'body' && styles.body,
        type === 'caption' && styles.caption,
        type === 'button' && styles.button,

        type === 'small' && styles.small,
        type === 'smallBold' && styles.smallBold,

        type === 'link' && styles.link,
        type === 'linkPrimary' && styles.linkPrimary,

        type === 'code' && styles.code,

        style,
      ]}
      {...rest}
    />
  );
}

const styles = StyleSheet.create({
  // Default body text
  default: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '500',
  },

  // Large Display
  title: {
    fontSize: 48,
    lineHeight: 56,
    fontWeight: '700',
  },

  // Section Title
  subtitle: {
    fontSize: 32,
    lineHeight: 40,
    fontWeight: '600',
  },

  // Headings
  h1: {
    fontSize: 40,
    lineHeight: 48,
    fontWeight: '700',
  },

  h2: {
    fontSize: 34,
    lineHeight: 42,
    fontWeight: '700',
  },

  h3: {
    fontSize: 30,
    lineHeight: 38,
    fontWeight: '700',
  },

  h4: {
    fontSize: 26,
    lineHeight: 34,
    fontWeight: '700',
  },

  h5: {
    fontSize: 22,
    lineHeight: 30,
    fontWeight: '600',
  },

  h6: {
    fontSize: 18,
    lineHeight: 26,
    fontWeight: '600',
  },

  // Body
  body: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '400',
  },

  // Caption
  caption: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '400',
  },

  // Buttons
  button: {
    fontSize: 16,
    lineHeight: 20,
    fontWeight: '700',
    textAlign: 'center',
  },

  // Small Text
  small: {
    fontSize: 14,
    lineHeight: 20,
    fontWeight: '500',
  },

  smallBold: {
    fontSize: 14,
    lineHeight: 20,
    fontWeight: '700',
  },

  // Links
  link: {
    fontSize: 14,
    lineHeight: 22,
    textDecorationLine: 'underline',
  },

  linkPrimary: {
    fontSize: 14,
    lineHeight: 22,
    color: '#3C87F7',
    fontWeight: '600',
    textDecorationLine: 'underline',
  },

  // Code
  code: {
    fontFamily: Fonts.mono,
    fontSize: 13,
    fontWeight: Platform.OS === 'android' ? '700' : '500',
  },
});