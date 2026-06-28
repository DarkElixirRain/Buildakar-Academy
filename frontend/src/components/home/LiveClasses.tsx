// components/home/LiveClasses.tsx
import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';

interface LiveClass {
  id: string;
  title: string;
  instructor: string;
  date: string;
  time: string;
  image: string;
  isLive?: boolean;
}

interface LiveClassesProps {
  classes: LiveClass[];
  onJoinPress: (classId: string) => void;
  onSeeAll: () => void;
}

export const LiveClasses: React.FC<LiveClassesProps> = ({
  classes,
  onJoinPress,
  onSeeAll,
}) => {
  const { isDarkMode, colors } = useTheme();

  return (
    <View style={{ width: '100%' }}>
      <View className="flex-row justify-between items-center mb-3">
        <View className="flex-row items-center">
          <Ionicons 
            name="videocam" 
            size={20} 
            color={isDarkMode ? colors.primary : '#7C3AED'} 
          />
          <Text style={{
            fontSize: 20,
            fontWeight: 'bold',
            marginLeft: 8,
            color: colors.text,
          }}>
            Live Classes
          </Text>
        </View>
        <TouchableOpacity onPress={onSeeAll} activeOpacity={0.7}>
          <Text style={{
            fontSize: 14,
            fontWeight: '600',
            color: colors.primary,
          }}>
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
        snapToInterval={260}
        snapToAlignment="start"
      >
        {classes.map((item) => (
          <TouchableOpacity
            key={item.id}
            style={{
              width: 256,
              marginRight: 16,
              borderRadius: 16,
              borderWidth: 1,
              overflow: 'hidden',
              backgroundColor: colors.backgroundElement,
              borderColor: colors.backgroundSelected,
              shadowColor: isDarkMode ? '#000000' : '#0F172A',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDarkMode ? 0.3 : 0.05,
              shadowRadius: 4,
              elevation: 2,
            }}
            onPress={() => onJoinPress(item.id)}
            activeOpacity={0.8}
          >
            <View className="relative">
              <Image 
                source={{ uri: item.image }}
                className="w-full h-32"
                resizeMode="cover"
              />
              
              {/* Live Badge */}
              {item.isLive && (
                <View style={{
                  position: 'absolute',
                  top: 8,
                  left: 8,
                  paddingHorizontal: 8,
                  paddingVertical: 2,
                  borderRadius: 12,
                  flexDirection: 'row',
                  alignItems: 'center',
                  backgroundColor: colors.primary,
                }}>
                  <View className="w-1.5 h-1.5 rounded-full bg-white mr-1 animate-pulse" />
                  <Text className="text-white text-xs font-bold">LIVE</Text>
                </View>
              )}

              {/* Upcoming Badge */}
              {!item.isLive && (
                <View className="absolute top-2 left-2 px-2 py-0.5 rounded-full flex-row items-center bg-black/60">
                  <Ionicons name="time-outline" size={10} color="white" />
                  <Text className="text-white text-xs font-bold ml-0.5">Upcoming</Text>
                </View>
              )}

              {/* Overlay gradient for better text readability */}
              <View className="absolute bottom-0 left-0 right-0 h-12 bg-gradient-to-t from-black/40 to-transparent" />
            </View>

            <View className="p-3">
              <Text style={{
                fontWeight: '600',
                fontSize: 14,
                marginBottom: 2,
                color: colors.text,
              }} numberOfLines={1}>
                {item.title}
              </Text>
              <Text style={{
                fontSize: 12,
                marginBottom: 8,
                color: colors.textSecondary,
              }}>
                {item.instructor}
              </Text>

              <View className="flex-row items-center justify-between mb-2">
                <View className="flex-row items-center">
                  <Ionicons name="calendar-outline" size={14} color={colors.textSecondary} />
                  <Text style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: colors.textSecondary,
                  }}>
                    {item.date}
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <Ionicons name="time-outline" size={14} color={colors.textSecondary} />
                  <Text style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: colors.textSecondary,
                  }}>
                    {item.time}
                  </Text>
                </View>
              </View>

              <TouchableOpacity 
                style={{
                  marginTop: 4,
                  paddingVertical: 6,
                  borderRadius: 20,
                  backgroundColor: isDarkMode ? '#8B5CF6' : '#7C3AED',
                }}
                onPress={() => onJoinPress(item.id)}
                activeOpacity={0.7}
              >
                <Text className="text-white text-center text-xs font-semibold">
                  {item.isLive ? 'Join Now' : 'Set Reminder'}
                </Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
};