// components/home/FeaturedCourses.tsx
import React, { useRef } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  FlatList, 
  Image, 
  Dimensions,
  Animated,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '@/context/themeContext';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 32;

interface FeaturedCourse {
  id: string;
  title: string;
  instructor: string;
  image: string;
  rating: number;
  isBestseller: boolean;
}

interface FeaturedCoursesProps {
  courses: FeaturedCourse[];
  onCoursePress: (courseId: string) => void;
}

export const FeaturedCourses: React.FC<FeaturedCoursesProps> = ({
  courses,
  onCoursePress,
}) => {
  const flatListRef = useRef<FlatList>(null);
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const scrollX = useRef(new Animated.Value(0)).current;
  const { isDarkMode, colors } = useTheme();

  React.useEffect(() => {
    const interval = setInterval(() => {
      const nextIndex = (currentIndex + 1) % courses.length;
      flatListRef.current?.scrollToIndex({
        index: nextIndex,
        animated: true,
      });
      setCurrentIndex(nextIndex);
    }, 5000);

    return () => clearInterval(interval);
  }, [currentIndex, courses.length]);

  const renderItem = ({ item }: { item: FeaturedCourse }) => (
    <TouchableOpacity
      style={{
        width: 350,
        marginRight: 16,
        borderRadius: 24,
        overflow: 'hidden',
      }}
      onPress={() => onCoursePress(item.id)}
      activeOpacity={0.9}
    >
      <View className="relative h-48">
        <Image 
          source={{ uri: item.image }}
          className="w-full h-full"
          resizeMode="cover"
        />
        <LinearGradient
          colors={['transparent', 'rgba(0,0,0,0.7)']}
          className="absolute inset-0"
        />
        
        {/* Bestseller Badge */}
        {item.isBestseller && (
          <View className="absolute top-3 left-3 bg-[#22C55E] px-3 py-1 rounded-full">
            <Text className="text-white text-xs font-bold">Bestseller</Text>
          </View>
        )}

        {/* Rating */}
        <View className="absolute top-3 right-3 bg-black/60 px-2.5 py-1 rounded-full flex-row items-center">
          <Ionicons name="star" size={14} color="#FBBF24" />
          <Text className="text-white text-xs font-medium ml-1">
            {item.rating.toFixed(1)}
          </Text>
        </View>

        {/* Content */}
        <View className="absolute bottom-0 left-0 right-0 p-4">
          <Text className="text-white font-bold text-lg mb-0.5" numberOfLines={1}>
            {item.title}
          </Text>
          <Text className="text-white/80 text-sm mb-2">
            {item.instructor}
          </Text>
          <View className="flex-row items-center">
            <TouchableOpacity 
              className="bg-white/20 backdrop-blur-sm px-5 py-2 rounded-full border border-white/20"
              onPress={() => onCoursePress(item.id)}
            >
              <Text className="text-white font-bold text-sm">
                Explore Course →
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );

  // ✅ FIX: Use useNativeDriver: false on web, true on native
  const useNativeDriver = Platform.OS !== 'web';

  return (
    <View style={{ width: '100%', marginBottom: 16 }}>
      <Text style={{ 
        fontSize: 20, 
        fontWeight: 'bold', 
        marginBottom: 12, 
        color: colors.text 
      }}>
        Featured Courses
      </Text>

      <FlatList
        ref={flatListRef}
        data={courses}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingRight: 20 }}
        decelerationRate="fast"
        snapToInterval={350 + 16}
        onScroll={Animated.event(
          [{ nativeEvent: { contentOffset: { x: scrollX } } }],
          { 
            useNativeDriver: useNativeDriver,
          }
        )}
        scrollEventThrottle={16}
      />

      {/* Dots Indicator */}
      <View className="flex-row justify-center mt-3">
        {courses.map((_, index) => {
          const inputRange = [
            (index - 1) * (350 + 16),
            index * (350 + 16),
            (index + 1) * (350 + 16),
          ];
          const dotWidth = scrollX.interpolate({
            inputRange,
            outputRange: [6, 20, 6],
            extrapolate: 'clamp',
          });
          const opacity = scrollX.interpolate({
            inputRange,
            outputRange: [0.3, 1, 0.3],
            extrapolate: 'clamp',
          });

          return (
            <Animated.View
              key={index}
              style={{
                height: 6,
                borderRadius: 3,
                marginHorizontal: 4,
                backgroundColor: colors.primary,
                width: dotWidth,
                opacity,
              }}
            />
          );
        })}
      </View>
    </View>
  );
};