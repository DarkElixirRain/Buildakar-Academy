// src/components/category/CategoryPicker.tsx
import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  Modal,
  FlatList,
  TextInput,
  ActivityIndicator,
  SafeAreaView,
} from "react-native";
import { useTheme } from "@/context/themeContext";
import { Ionicons } from "@expo/vector-icons";
import { categoryService } from "@/services/categoryService";

interface Category {
  id: string;
  name: string;
  slug?: string;
  description?: string;
  icon?: string;
  color?: string;
  parentId?: string | null;
  children?: Category[];
}

interface CategoryPickerProps {
  selectedCategoryId?: string;
  onSelectCategory: (categoryId: string) => void;
  placeholder?: string;
  error?: string;
  disabled?: boolean;
}

export const CategoryPicker: React.FC<CategoryPickerProps> = ({
  selectedCategoryId,
  onSelectCategory,
  placeholder = "Select a category",
  error,
  disabled = false,
}) => {
  const { colors, isDarkMode } = useTheme();
  const [modalVisible, setModalVisible] = useState(false);
  const [categories, setCategories] = useState<Category[]>([]);
  const [filteredCategories, setFilteredCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);

  useEffect(() => {
    loadCategories();
  }, []);

  useEffect(() => {
    if (selectedCategoryId && categories.length > 0) {
      const found = findCategoryById(categories, selectedCategoryId);
      setSelectedCategory(found || null);
    }
  }, [selectedCategoryId, categories]);

  useEffect(() => {
    if (searchQuery.trim()) {
      const filtered = categories.filter((cat) =>
        cat.name.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredCategories(filtered);
    } else {
      setFilteredCategories(categories);
    }
  }, [searchQuery, categories]);

  const loadCategories = async () => {
    try {
      setLoading(true);
      const data = await categoryService.getCategories();
      setCategories(data);
      setFilteredCategories(data);
    } catch (error) {
      console.error("Failed to load categories:", error);
    } finally {
      setLoading(false);
    }
  };

  const findCategoryById = (items: Category[], id: string): Category | null => {
    for (const item of items) {
      if (item.id === id) return item;
      if (item.children) {
        const found = findCategoryById(item.children, id);
        if (found) return found;
      }
    }
    return null;
  };

  const handleSelectCategory = (category: Category) => {
    setSelectedCategory(category);
    onSelectCategory(category.id);
    setModalVisible(false);
  };

  const renderCategoryItem = ({ item, level = 0 }: { item: Category; level?: number }) => {
    const isSelected = selectedCategory?.id === item.id;
    const paddingLeft = 16 + level * 16;

    return (
      <>
        <TouchableOpacity
          style={{
            flexDirection: "row",
            alignItems: "center",
            paddingVertical: 12,
            paddingHorizontal: 16,
            paddingLeft,
            backgroundColor: isSelected ? colors.primary + "20" : "transparent",
            borderBottomWidth: 1,
            borderBottomColor: colors.backgroundSelected,
          }}
          onPress={() => handleSelectCategory(item)}
          disabled={disabled}
        >
          {item.icon && (
            <Ionicons
              name={item.icon as any}
              size={20}
              color={isSelected ? colors.primary : colors.textSecondary}
              style={{ marginRight: 12 }}
            />
          )}
          <View style={{ flex: 1 }}>
            <Text
              style={{
                fontSize: 16,
                color: isSelected ? colors.primary : colors.text,
                fontWeight: isSelected ? "600" : "400",
              }}
            >
              {item.name}
            </Text>
            {item.description && (
              <Text
                style={{
                  fontSize: 12,
                  color: colors.textSecondary,
                  marginTop: 2,
                }}
              >
                {item.description}
              </Text>
            )}
          </View>
          {isSelected && (
            <Ionicons name="checkmark-circle" size={20} color={colors.primary} />
          )}
        </TouchableOpacity>
        {item.children && item.children.length > 0 && (
          <View>
            {item.children.map((child) => (
              <View key={child.id}>
                {renderCategoryItem({ item: child, level: level + 1 })}
              </View>
            ))}
          </View>
        )}
      </>
    );
  };

  return (
    <View>
      <TouchableOpacity
        style={{
          backgroundColor: colors.backgroundElement,
          borderRadius: 12,
          padding: 16,
          borderWidth: 2,
          borderColor: error ? "#EF4444" : colors.backgroundSelected,
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "space-between",
          opacity: disabled ? 0.6 : 1,
        }}
        onPress={() => !disabled && setModalVisible(true)}
        disabled={disabled}
      >
        <View style={{ flex: 1 }}>
          {selectedCategory ? (
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              {selectedCategory.icon && (
                <Ionicons
                  name={selectedCategory.icon as any}
                  size={20}
                  color={colors.primary}
                  style={{ marginRight: 8 }}
                />
              )}
              <Text style={{ fontSize: 16, color: colors.text }}>
                {selectedCategory.name}
              </Text>
            </View>
          ) : (
            <Text style={{ fontSize: 16, color: colors.textSecondary }}>
              {placeholder}
            </Text>
          )}
        </View>
        <Ionicons name="chevron-down" size={20} color={colors.textSecondary} />
      </TouchableOpacity>

      {error && (
        <Text style={{ color: "#EF4444", fontSize: 12, marginTop: 4 }}>
          {error}
        </Text>
      )}

      <Modal
        animationType="slide"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => setModalVisible(false)}
      >
        <SafeAreaView style={{ flex: 1, backgroundColor: "rgba(0,0,0,0.5)" }}>
          <View
            style={{
              flex: 1,
              marginTop: 60,
              backgroundColor: colors.background,
              borderTopLeftRadius: 20,
              borderTopRightRadius: 20,
            }}
          >
            {/* Header */}
            <View
              style={{
                flexDirection: "row",
                alignItems: "center",
                justifyContent: "space-between",
                padding: 16,
                borderBottomWidth: 1,
                borderBottomColor: colors.backgroundSelected,
              }}
            >
              <Text style={{ fontSize: 18, fontWeight: "700", color: colors.text }}>
                Select Category
              </Text>
              <TouchableOpacity onPress={() => setModalVisible(false)}>
                <Ionicons name="close" size={24} color={colors.text} />
              </TouchableOpacity>
            </View>

            {/* Search Bar */}
            <View
              style={{
                flexDirection: "row",
                alignItems: "center",
                paddingHorizontal: 16,
                paddingVertical: 12,
                backgroundColor: colors.backgroundElement,
                margin: 16,
                borderRadius: 12,
                borderWidth: 1,
                borderColor: colors.backgroundSelected,
              }}
            >
              <Ionicons name="search" size={20} color={colors.textSecondary} />
              <TextInput
                style={{
                  flex: 1,
                  marginLeft: 8,
                  fontSize: 16,
                  color: colors.text,
                  paddingVertical: 4,
                }}
                placeholder="Search categories..."
                placeholderTextColor={colors.textSecondary}
                value={searchQuery}
                onChangeText={setSearchQuery}
                autoFocus
              />
              {searchQuery.length > 0 && (
                <TouchableOpacity onPress={() => setSearchQuery("")}>
                  <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
                </TouchableOpacity>
              )}
            </View>

            {/* Categories List */}
            {loading ? (
              <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
                <ActivityIndicator size="large" color={colors.primary} />
              </View>
            ) : filteredCategories.length === 0 ? (
              <View style={{ flex: 1, justifyContent: "center", alignItems: "center", padding: 40 }}>
                <Ionicons name="folder-open-outline" size={64} color={colors.textSecondary} />
                <Text style={{ fontSize: 16, color: colors.textSecondary, marginTop: 16, textAlign: "center" }}>
                  No categories found
                </Text>
                <Text style={{ fontSize: 14, color: colors.textSecondary + "80", marginTop: 8, textAlign: "center" }}>
                  Try a different search term
                </Text>
              </View>
            ) : (
              <FlatList
                data={filteredCategories}
                keyExtractor={(item) => item.id}
                renderItem={renderCategoryItem}
                contentContainerStyle={{ paddingBottom: 80 }}
                showsVerticalScrollIndicator={false}
              />
            )}
          </View>
        </SafeAreaView>
      </Modal>
    </View>
  );
};

export default CategoryPicker;