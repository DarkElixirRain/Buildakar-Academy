// components/home/LiveClasses.tsx

import { View, Text, TouchableOpacity, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

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
  return (
    <View className="w-full">
      <View className="flex-row justify-between items-center mb-3">
        <Text className="text-[#0F172A] text-xl font-bold">
          Live Classes
        </Text>
        <TouchableOpacity onPress={onSeeAll}>
          <Text className="text-[#2563EB] text-sm font-semibold">
            See All
          </Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
      >
        {classes.map((item) => (
          <TouchableOpacity
            key={item.id}
            className="w-64 mr-4 bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden"
            onPress={() => onJoinPress(item.id)}
            activeOpacity={0.8}
            style={{
              shadowColor: '#0F172A',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.05,
              shadowRadius: 4,
              elevation: 2,
            }}
          >
            <View className="relative">
              <Image 
                source={{ uri: item.image }}
                className="w-full h-32"
                resizeMode="cover"
              />
              
              {item.isLive && (
                <View className="absolute top-2 left-2 bg-[#EF4444] px-2 py-0.5 rounded-full flex-row items-center">
                  <View className="w-1.5 h-1.5 rounded-full bg-white mr-1 animate-pulse" />
                  <Text className="text-white text-xs font-bold">LIVE</Text>
                </View>
              )}
            </View>

            <View className="p-3">
              <Text className="text-[#0F172A] font-semibold text-sm mb-0.5" numberOfLines={1}>
                {item.title}
              </Text>
              <Text className="text-[#64748B] text-xs mb-2">
                {item.instructor}
              </Text>

              <View className="flex-row items-center justify-between">
                <View className="flex-row items-center">
                  <Ionicons name="calendar-outline" size={14} color="#64748B" />
                  <Text className="text-[#64748B] text-xs ml-1">
                    {item.date}
                  </Text>
                </View>
                <View className="flex-row items-center">
                  <Ionicons name="time-outline" size={14} color="#64748B" />
                  <Text className="text-[#64748B] text-xs ml-1">
                    {item.time}
                  </Text>
                </View>
              </View>

              <TouchableOpacity 
                className="mt-2.5 bg-[#7C3AED] py-1.5 rounded-full"
                onPress={() => onJoinPress(item.id)}
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