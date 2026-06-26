import { ScrollView, StyleSheet, View, Text, Image, Pressable } from 'react-native';
import { ThemedView } from '@/components/themed-view';
import { HomeHeader } from '../../../components/home/HomeHeader';

export default function TabTwoScreen() {
  const courses = [
    {
      id: 1,
      title: 'Machine Learning Specialization',
      provider: 'Stanford University',
      rating: 4.9,
      students: '1.2M',
      image: 'https://via.placeholder.com/300x150',
      price: 'Free',
    },
    {
      id: 2,
      title: 'Google UX Design Certificate',
      provider: 'Google',
      rating: 4.8,
      students: '850K',
      image: 'https://via.placeholder.com/300x150',
      price: '$39/month',
    },
    {
      id: 3,
      title: 'IBM Data Science Professional',
      provider: 'IBM',
      rating: 4.7,
      students: '650K',
      image: 'https://via.placeholder.com/300x150',
      price: 'Free',
    },
    {
      id: 4,
      title: 'Deep Learning Specialization',
      provider: 'DeepLearning.AI',
      rating: 4.9,
      students: '950K',
      image: 'https://via.placeholder.com/300x150',
      price: '$49/month',
    },
    {
      id: 5,
      title: 'Business Foundations',
      provider: 'University of Pennsylvania',
      rating: 4.6,
      students: '450K',
      image: 'https://via.placeholder.com/300x150',
      price: 'Free',
    },
    {
      id: 6,
      title: 'Python for Everybody',
      provider: 'University of Michigan',
      rating: 4.8,
      students: '2.1M',
      image: 'https://via.placeholder.com/300x150',
      price: 'Free',
    },
  ];

  return (
    <View style={styles.mainContainer}>
      {/* Fixed Header - spans full width from left to right */}
      <View style={styles.fixedHeaderContainer}>
        <HomeHeader 
          notificationCount={0} 
          onNotificationPress={function (): void {
            throw new Error('Function not implemented.');
          }} 
        />
      </View>
      
      {/* Scrollable Content */}
      <ScrollView 
        style={styles.scrollView} 
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        <ThemedView style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.headerTitle}>Explore Courses</Text>
            <Text style={styles.headerSubtitle}>Find the best courses for your career</Text>
          </View>

          <View style={styles.categoriesContainer}>
            <Pressable style={[styles.categoryButton, styles.categoryButtonActive]}>
              <Text style={[styles.categoryText, styles.categoryTextActive]}>All</Text>
            </Pressable>
            <Pressable style={styles.categoryButton}>
              <Text style={styles.categoryText}>Data Science</Text>
            </Pressable>
            <Pressable style={styles.categoryButton}>
              <Text style={styles.categoryText}>Business</Text>
            </Pressable>
            <Pressable style={styles.categoryButton}>
              <Text style={styles.categoryText}>Technology</Text>
            </Pressable>
          </View>

          <View style={styles.coursesGrid}>
            {courses.map((course) => (
              <Pressable key={course.id} style={styles.courseCard}>
                <Image source={{ uri: course.image }} style={styles.courseImage} />
                <View style={styles.courseInfo}>
                  <Text style={styles.courseTitle} numberOfLines={2}>
                    {course.title}
                  </Text>
                  <Text style={styles.courseProvider}>{course.provider}</Text>
                  <View style={styles.courseDetails}>
                    <Text style={styles.courseRating}>⭐ {course.rating}</Text>
                    <Text style={styles.courseStudents}>{course.students} students</Text>
                  </View>
                  <View style={styles.courseFooter}>
                    <Text style={styles.coursePrice}>{course.price}</Text>
                    <Pressable style={styles.enrollButton}>
                      <Text style={styles.enrollButtonText}>Enroll</Text>
                    </Pressable>
                  </View>
                </View>
              </Pressable>
            ))}
          </View>
        </ThemedView>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  fixedHeaderContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
    backgroundColor: '#FFFFFF',
    // Add shadow for better visual separation
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  scrollView: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollContent: {
    paddingTop: 80, // Adjust this value based on your HomeHeader height
  },
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  header: {
    marginTop: 8,
    marginBottom: 20,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
    marginBottom: 4,
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#666666',
  },
  categoriesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 20,
  },
  categoryButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#F5F5F5',
    borderRadius: 20,
    marginRight: 8,
    marginBottom: 8,
  },
  categoryButtonActive: {
    backgroundColor: '#0056D2',
  },
  categoryText: {
    color: '#666666',
    fontSize: 14,
  },
  categoryTextActive: {
    color: '#FFFFFF',
  },
  coursesGrid: {
    gap: 16,
  },
  courseCard: {
    backgroundColor: '#F8F8F8',
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#EEEEEE',
  },
  courseImage: {
    width: '100%',
    height: 150,
    backgroundColor: '#E0E0E0',
  },
  courseInfo: {
    padding: 12,
  },
  courseTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 4,
  },
  courseProvider: {
    fontSize: 14,
    color: '#666666',
    marginBottom: 8,
  },
  courseDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  courseRating: {
    fontSize: 14,
    color: '#000000',
  },
  courseStudents: {
    fontSize: 14,
    color: '#666666',
  },
  courseFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  coursePrice: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#000000',
  },
  enrollButton: {
    backgroundColor: '#0056D2',
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 6,
  },
  enrollButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
});