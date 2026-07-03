import { View, type ViewProps } from 'react-native';

import { ThemeColor } from '@/constants/theme';
import { useTheme } from '@/context/themeContext';

export type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
  type?: ThemeColor;
};

export function ThemedView({ style, lightColor, darkColor, type, ...otherProps }: ThemedViewProps) {
  const { colors, isDarkMode } = useTheme();

  const backgroundColor = type ? colors[type] : colors.background;

  return <View style={[{ backgroundColor }, style]} {...otherProps} />;
}
