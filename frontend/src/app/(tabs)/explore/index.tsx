import { ScrollView, StyleSheet, View, Text, Image, Pressable, TextInput } from 'react-native';
import { ThemedView } from '@/components/themed-view';
import { HomeHeader } from '../../../components/home/HomeHeader';
import { useState } from 'react';

// Dummy image URLs (using picsum for random images)
const DUMMY_IMAGES = {
  ml: 'https://picsum.photos/seed/ml/400/200',
  ux: 'https://picsum.photos/seed/ux/400/200',
  data: 'https://picsum.photos/seed/data/400/200',
  deep: 'https://picsum.photos/seed/deep/400/200',
  business: 'https://picsum.photos/seed/business/400/200',
  python: 'https://picsum.photos/seed/python/400/200',
  design: 'https://picsum.photos/seed/design/400/200',
  cloud: 'https://picsum.photos/seed/cloud/400/200',
};

export default function TabTwoScreen() {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');

  const categories = ['All', 'Data Science', 'Business', 'Technology', 'Design', 'Cloud'];

  const courses = [
    {
      id: 1,
      title: 'Machine Learning Specialization',
      provider: 'Stanford University',
      rating: 4.9,
      reviews: 12450,
      students: '1.2M',
      image: DUMMY_IMAGES.ml,
      price: 'Free',
      category: 'Data Science',
      level: 'Advanced',
      duration: '3 months',
    },
    {
      id: 2,
      title: 'Google UX Design Certificate',
      provider: 'Google',
      rating: 4.8,
      reviews: 8450,
      students: '850K',
      image: DUMMY_IMAGES.ux,
      price: '$39/mo',
      category: 'Design',
      level: 'Beginner',
      duration: '6 months',
    },
    {
      id: 3,
      title: 'IBM Data Science Professional',
      provider: 'IBM',
      rating: 4.7,
      reviews: 6500,
      students: '650K',
      image: DUMMY_IMAGES.data,
      price: 'Free',
      category: 'Data Science',
      level: 'Intermediate',
      duration: '4 months',
    },
    {
      id: 4,
      title: 'Deep Learning Specialization',
      provider: 'DeepLearning.AI',
      rating: 4.9,
      reviews: 9500,
      students: '950K',
      image: DUMMY_IMAGES.deep,
      price: '$49/mo',
      category: 'Technology',
      level: 'Advanced',
      duration: '5 months',
    },
    {
      id: 5,
      title: 'Business Foundations',
      provider: 'University of Pennsylvania',
      rating: 4.6,
      reviews: 4500,
      students: '450K',
      image: DUMMY_IMAGES.business,
      price: 'Free',
      category: 'Business',
      level: 'Beginner',
      duration: '2 months',
    },
    {
      id: 6,
      title: 'Python for Everybody',
      provider: 'University of Michigan',
      rating: 4.8,
      reviews: 21000,
      students: '2.1M',
      image: DUMMY_IMAGES.python,
      price: 'Free',
      category: 'Technology',
      level: 'Beginner',
      duration: '3 months',
    },
    {
      id: 7,
      title: 'Graphic Design Specialization',
      provider: 'California Institute of the Arts',
      rating: 4.7,
      reviews: 5600,
      students: '320K',
      image: DUMMY_IMAGES.design,
      price: '$29/mo',
      category: 'Design',
      level: 'Intermediate',
      duration: '4 months',
    },
    {
      id: 8,
      title: 'Cloud Computing Fundamentals',
      provider: 'Amazon Web Services',
      rating: 4.5,
      reviews: 3800,
      students: '280K',
      image: DUMMY_IMAGES.cloud,
      price: 'Free',
      category: 'Cloud',
      level: 'Beginner',
      duration: '2 months',
    },
  ];

  const filteredCourses = courses.filter(course => {
    const matchesCategory = selectedCategory === 'All' || course.category === selectedCategory;
    const matchesSearch = course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          course.provider.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const getLevelColor = (level: string) => {
    switch(level) {
      case 'Beginner': return '#4CAF50';
      case 'Intermediate': return '#FF9800';
      case 'Advanced': return '#F44336';
      default: return '#666';
    }
  };

  return (
    <View style={styles.mainContainer}>
      {/* Fixed Header */}
      <View style={styles.fixedHeaderContainer}>
        <HomeHeader 
          notificationCount={3} 
          onNotificationPress={() => {}} 
        />
      </View>
      
      {/* Scrollable Content */}
      <ScrollView 
        style={styles.scrollView} 
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        <ThemedView style={styles.container}>
          {/* Search Bar */}
          <View style={styles.searchContainer}>
            <View style={styles.searchBar}>
              <Text style={styles.searchIcon}>🔍</Text>
              <TextInput
                style={styles.searchInput}
                placeholder="Search courses..."
                placeholderTextColor="#999"
                value={searchQuery}
                onChangeText={setSearchQuery}
              />
              {searchQuery.length > 0 && (
                <Pressable onPress={() => setSearchQuery('')}>
                  <Text style={styles.clearIcon}>✕</Text>
                </Pressable>
              )}
            </View>
          </View>

          {/* Header Section */}
          <View style={styles.header}>
            <View>
              <Text style={styles.headerTitle}>Explore Courses</Text>
              <Text style={styles.headerSubtitle}>Discover your next learning adventure</Text>
            </View>
            <Pressable style={styles.filterButton}>
              <Text style={styles.filterIcon}>⚙️</Text>
            </Pressable>
          </View>

          {/* Categories */}
          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            style={styles.categoriesScroll}
            contentContainerStyle={styles.categoriesContainer}
          >
            {categories.map((category) => (
              <Pressable
                key={category}
                style={[
                  styles.categoryButton,
                  selectedCategory === category && styles.categoryButtonActive
                ]}
                onPress={() => setSelectedCategory(category)}
              >
                <Text style={[
                  styles.categoryText,
                  selectedCategory === category && styles.categoryTextActive
                ]}>
                  {category}
                </Text>
              </Pressable>
            ))}
          </ScrollView>

          {/* Results Count */}
          <View style={styles.resultsContainer}>
            <Text style={styles.resultsText}>
              {filteredCourses.length} courses found
            </Text>
          </View>

          {/* Course Grid */}
          <View style={styles.coursesGrid}>
            {filteredCourses.map((course) => (
              <Pressable key={course.id} style={styles.courseCard}>
                <Image source={{ uri: course.image }} style={styles.courseImage} />
                
                {/* Level Badge */}
                <View style={[styles.levelBadge, { backgroundColor: getLevelColor(course.level) }]}>
                  <Text style={styles.levelText}>{course.level}</Text>
                </View>

                <View style={styles.courseInfo}>
                  <Text style={styles.courseTitle} numberOfLines={2}>
                    {course.title}
                  </Text>
                  <Text style={styles.courseProvider}>{course.provider}</Text>
                  
                  <View style={styles.ratingContainer}>
                    <View style={styles.ratingRow}>
                      <Text style={styles.starIcon}>⭐</Text>
                      <Text style={styles.courseRating}>{course.rating}</Text>
                      <Text style={styles.reviewCount}>({course.reviews.toLocaleString()} reviews)</Text>
                    </View>
                    <View style={styles.studentsRow}>
                      <Text style={styles.studentIcon}>👨‍🎓</Text>
                      <Text style={styles.courseStudents}>{course.students} students</Text>
                    </View>
                  </View>

                  <View style={styles.courseMeta}>
                    <View style={styles.metaItem}>
                      <Text style={styles.metaIcon}>⏱️</Text>
                      <Text style={styles.metaText}>{course.duration}</Text>
                    </View>
                    <View style={styles.metaItem}>
                      <Text style={styles.metaIcon}>📚</Text>
                      <Text style={styles.metaText}>{course.category}</Text>
                    </View>
                  </View>

                  <View style={styles.courseFooter}>
                    <View>
                      <Text style={styles.priceLabel}>Price</Text>
                      <Text style={styles.coursePrice}>{course.price}</Text>
                    </View>
                    <Pressable style={styles.enrollButton}>
                      <Text style={styles.enrollButtonText}>Enroll Now →</Text>
                    </Pressable>
                  </View>
                </View>
              </Pressable>
            ))}
          </View>

          {/* Bottom spacing */}
          <View style={{ height: 40 }} />
        </ThemedView>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  fixedHeaderContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
    backgroundColor: '#FFFFFF',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 4,
  },
  scrollView: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  scrollContent: {
    paddingTop: 80,
  },
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  searchContainer: {
    marginBottom: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  searchIcon: {
    fontSize: 18,
    marginRight: 12,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#1A202C',
    padding: 0,
  },
  clearIcon: {
    fontSize: 16,
    color: '#A0AEC0',
    padding: 4,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1A202C',
    marginBottom: 4,
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#718096',
  },
  filterButton: {
    width: 44,
    height: 44,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  filterIcon: {
    fontSize: 20,
  },
  categoriesScroll: {
    marginBottom: 12,
  },
  categoriesContainer: {
    paddingVertical: 4,
    gap: 8,
  },
  categoryButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    marginRight: 8,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  categoryButtonActive: {
    backgroundColor: '#0056D2',
    borderColor: '#0056D2',
  },
  categoryText: {
    color: '#4A5568',
    fontSize: 14,
    fontWeight: '500',
  },
  categoryTextActive: {
    color: '#FFFFFF',
  },
  resultsContainer: {
    marginBottom: 12,
  },
  resultsText: {
    fontSize: 13,
    color: '#718096',
    fontWeight: '500',
  },
  coursesGrid: {
    gap: 16,
  },
  courseCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
  courseImage: {
    width: '100%',
    height: 180,
    backgroundColor: '#EDF2F7',
  },
  levelBadge: {
    position: 'absolute',
    top: 12,
    right: 12,
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    backgroundColor: '#4CAF50',
  },
  levelText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '600',
  },
  courseInfo: {
    padding: 16,
  },
  courseTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: '#1A202C',
    marginBottom: 4,
    lineHeight: 22,
  },
  courseProvider: {
    fontSize: 14,
    color: '#718096',
    marginBottom: 12,
  },
  ratingContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
    paddingVertical: 8,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: '#F7FAFC',
  },
  ratingRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  starIcon: {
    fontSize: 16,
    marginRight: 4,
  },
  courseRating: {
    fontSize: 15,
    fontWeight: '600',
    color: '#1A202C',
    marginRight: 4,
  },
  reviewCount: {
    fontSize: 13,
    color: '#A0AEC0',
  },
  studentsRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  studentIcon: {
    fontSize: 14,
    marginRight: 4,
  },
  courseStudents: {
    fontSize: 13,
    color: '#718096',
  },
  courseMeta: {
    flexDirection: 'row',
    gap: 16,
    marginBottom: 12,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  metaIcon: {
    fontSize: 14,
    marginRight: 4,
  },
  metaText: {
    fontSize: 13,
    color: '#4A5568',
  },
  courseFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 12,
    borderTopWidth: 1,
    borderColor: '#F7FAFC',
  },
  priceLabel: {
    fontSize: 11,
    color: '#A0AEC0',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  coursePrice: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0056D2',
  },
  enrollButton: {
    backgroundColor: '#0056D2',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  enrollButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
});