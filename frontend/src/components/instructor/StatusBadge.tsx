// components/instructor/StatusBadge.tsx
import React from 'react';
import { Text, View } from 'react-native';
import { courseStatusColors, courseLevelColors } from '@/types/instructor';

interface StatusBadgeProps {
  status: 'DRAFT' | 'UNDER_REVIEW' | 'PUBLISHED';
  size?: 'sm' | 'md' | 'lg';
  showDot?: boolean;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ 
  status, 
  size = 'md', 
  showDot = true 
}) => {
  const colors = courseStatusColors[status];
  const label = status.replace('_', ' ');

  const sizes = {
    sm: { paddingX: 8, paddingY: 2, fontSize: 10, dotSize: 6 },
    md: { paddingX: 10, paddingY: 4, fontSize: 12, dotSize: 8 },
    lg: { paddingX: 12, paddingY: 6, fontSize: 14, dotSize: 10 },
  };

  const s = sizes[size];

  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.bg,
        borderRadius: 20,
        paddingHorizontal: s.paddingX,
        paddingVertical: s.paddingY,
      }}
    >
      {showDot && (
        <View
          style={{
            width: s.dotSize,
            height: s.dotSize,
            borderRadius: s.dotSize / 2,
            backgroundColor: colors.dot,
            marginRight: 6,
          }}
        />
      )}
      <Text
        style={{
          color: colors.text,
          fontSize: s.fontSize,
          fontWeight: '600',
          textTransform: 'capitalize',
        }}
      >
        {label}
      </Text>
    </View>
  );
};

interface LevelBadgeProps {
  level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
  size?: 'sm' | 'md' | 'lg';
}

export const LevelBadge: React.FC<LevelBadgeProps> = ({ level, size = 'md' }) => {
  const colors = courseLevelColors[level];

  const sizes = {
    sm: { paddingX: 8, paddingY: 2, fontSize: 10 },
    md: { paddingX: 10, paddingY: 4, fontSize: 12 },
    lg: { paddingX: 12, paddingY: 6, fontSize: 14 },
  };

  const s = sizes[size];

  return (
    <View
      style={{
        backgroundColor: colors.bg,
        borderRadius: 20,
        paddingHorizontal: s.paddingX,
        paddingVertical: s.paddingY,
      }}
    >
      <Text
        style={{
          color: colors.text,
          fontSize: s.fontSize,
          fontWeight: '600',
        }}
      >
        {level}
      </Text>
    </View>
  );
};

export default StatusBadge;