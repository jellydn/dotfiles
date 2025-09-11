# React Native Style Guide

*Modern React Native development patterns, performance optimization, and best practices for 2025.*

## Table of Contents

1. [New Architecture (Fabric & TurboModules)](#new-architecture-fabric--turbomodules)
2. [Project Setup](#project-setup)
3. [Project Structure](#project-structure)
4. [Component Patterns](#component-patterns)
5. [Performance Optimization](#performance-optimization)
6. [State Management](#state-management)
7. [Navigation](#navigation)
8. [Platform-Specific Code](#platform-specific-code)
9. [Styling Approaches](#styling-approaches)
10. [Native Modules](#native-modules)
11. [Testing Strategies](#testing-strategies)
12. [Accessibility](#accessibility)
13. [Build & Deployment](#build--deployment)
14. [Best Practices](#best-practices)

---

## New Architecture (Fabric & TurboModules)

### JSI (JavaScript Interface)

The JavaScript Interface enables direct, synchronous communication between JavaScript and native code.

```typescript
// Modern JSI-based native module
import { NativeModules } from 'react-native';

interface BiometricModule {
  authenticate(): Promise<boolean>;
  isAvailable(): boolean; // Synchronous JSI call
}

const { BiometricModule } = NativeModules as { BiometricModule: BiometricModule };

// Synchronous call via JSI
const isBiometricAvailable = BiometricModule.isAvailable();
```

### TurboModules Integration

```typescript
// TurboModule spec using CodeGen
// NativeImageProcessor.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  processImage(uri: string, filters: Object): Promise<string>;
  getCacheSize(): number; // Synchronous
}

export default TurboModuleRegistry.getEnforcing<Spec>('ImageProcessor');
```

### Fabric Component Spec

```typescript
// Component spec for Fabric
// MapViewNativeComponent.ts
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

interface MapViewProps extends ViewProps {
  latitude: number;
  longitude: number;
  zoom?: number;
}

export default codegenNativeComponent<MapViewProps>('MapView');
```

---

## Project Setup

### React Native CLI Setup

```bash
# Create new React Native project
npx react-native@latest init MyApp --template react-native-template-typescript

# iOS setup
cd MyApp/ios && pod install

# Run on iOS
npx react-native run-ios

# Run on Android
npx react-native run-android
```

### Essential Dependencies

```bash
# Navigation
npm install @react-navigation/native @react-navigation/native-stack
npm install react-native-screens react-native-safe-area-context

# iOS specific
cd ios && pod install

# State management
npm install zustand @tanstack/react-query

# Utilities
npm install react-native-reanimated react-native-gesture-handler
npm install @react-native-async-storage/async-storage
npm install react-native-keychain

# Development
npm install --save-dev @types/react @types/react-native
npm install --save-dev jest @testing-library/react-native
```

### TypeScript Configuration

```json
{
  "extends": "@react-native/typescript-config/tsconfig.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/types/*": ["./src/types/*"]
    },
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*", "index.js"],
  "exclude": ["node_modules"]
}
```

### Metro Configuration

```javascript
// metro.config.js
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const config = {
  resolver: {
    alias: {
      '@': './src',
    },
  },
  transformer: {
    unstable_allowRequireContext: true,
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

---

## Project Structure

### Standard React Native Structure

```
MyApp/
├── src/
│   ├── components/            # Reusable components
│   │   ├── ui/               # Base UI components
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   └── Modal/
│   │   └── forms/            # Form components
│   ├── screens/              # Screen components
│   │   ├── HomeScreen.tsx
│   │   ├── ProfileScreen.tsx
│   │   └── SettingsScreen.tsx
│   ├── navigation/           # Navigation configuration
│   │   ├── AppNavigator.tsx
│   │   ├── TabNavigator.tsx
│   │   └── types.ts
│   ├── hooks/                # Custom hooks
│   │   ├── useAuth.ts
│   │   ├── useApi.ts
│   │   └── useStorage.ts
│   ├── services/             # API & business logic
│   │   ├── api/
│   │   │   ├── auth.ts
│   │   │   └── users.ts
│   │   ├── auth.ts
│   │   └── storage.ts
│   ├── stores/               # State management
│   │   ├── authStore.ts
│   │   └── userStore.ts
│   ├── utils/                # Utilities
│   │   ├── validation.ts
│   │   ├── constants.ts
│   │   └── helpers.ts
│   ├── types/                # TypeScript definitions
│   │   ├── api.ts
│   │   ├── navigation.ts
│   │   └── user.ts
│   └── styles/               # Global styles
│       ├── colors.ts
│       ├── typography.ts
│       └── spacing.ts
├── android/                  # Android native code
├── ios/                      # iOS native code
├── __tests__/                # Test files
├── assets/                   # Static assets
│   ├── images/
│   ├── fonts/
│   └── icons/
├── index.js                  # Entry point
├── package.json
└── tsconfig.json
```

### Component Organization

```typescript
// src/components/Button/index.ts
export { default } from './Button';
export type { ButtonProps } from './Button.types';

// src/components/Button/Button.tsx
import React from 'react';
import { Pressable, Text, StyleSheet } from 'react-native';
import type { ButtonProps } from './Button.types';

const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'medium',
  children,
  onPress,
  disabled = false,
  style,
  ...props
}) => {
  return (
    <Pressable
      style={[
        styles.button,
        styles[variant],
        styles[size],
        disabled && styles.disabled,
        style,
      ]}
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      {...props}
    >
      <Text style={[styles.text, styles[`${variant}Text`]]}>{children}</Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: {
    backgroundColor: '#007AFF',
  },
  secondary: {
    backgroundColor: '#5856D6',
  },
  small: {
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  medium: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  large: {
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
  disabled: {
    opacity: 0.6,
  },
  text: {
    fontWeight: '600',
  },
  primaryText: {
    color: 'white',
  },
  secondaryText: {
    color: 'white',
  },
});

export default Button;
```

---

## Component Patterns

### Functional Components with Hooks

```typescript
import React, { useCallback, useMemo } from 'react';
import { FlatList, RefreshControl } from 'react-native';
import { useQuery } from '@tanstack/react-query';

interface UserListProps {
  category?: string;
}

const UserList: React.FC<UserListProps> = ({ category }) => {
  const { data: users, isLoading, refetch } = useQuery({
    queryKey: ['users', category],
    queryFn: () => fetchUsers(category),
  });

  // Memoize renderItem to prevent unnecessary re-renders
  const renderItem = useCallback(({ item }: { item: User }) => (
    <UserCard user={item} />
  ), []);

  const keyExtractor = useCallback((item: User) => item.id, []);

  // Memoize filtered data
  const filteredUsers = useMemo(
    () => users?.filter(user => user.status === 'active') ?? [],
    [users]
  );

  return (
    <FlatList
      data={filteredUsers}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      refreshControl={
        <RefreshControl refreshing={isLoading} onRefresh={refetch} />
      }
      // Performance optimizations
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      windowSize={21}
      initialNumToRender={10}
      updateCellsBatchingPeriod={50}
    />
  );
};
```

### Memoized Components

```typescript
import React, { memo } from 'react';
import { View, Text, StyleSheet } from 'react-native';

interface UserCardProps {
  user: User;
  onPress?: (user: User) => void;
}

const UserCard = memo<UserCardProps>(
  ({ user, onPress }) => (
    <View style={styles.card}>
      <Text style={styles.name}>{user.name}</Text>
      <Text style={styles.email}>{user.email}</Text>
    </View>
  ),
  (prevProps, nextProps) => {
    // Custom comparison for optimal re-rendering
    return (
      prevProps.user.id === nextProps.user.id &&
      prevProps.user.name === nextProps.user.name &&
      prevProps.user.email === nextProps.user.email &&
      prevProps.onPress === nextProps.onPress
    );
  }
);

const styles = StyleSheet.create({
  card: {
    padding: 16,
    marginVertical: 4,
    backgroundColor: 'white',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 2,
    elevation: 3,
  },
  name: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  email: {
    fontSize: 14,
    color: '#666',
  },
});
```

### Custom Hooks Pattern

```typescript
// hooks/useImagePicker.ts
import { useState } from 'react';
import { launchImageLibrary, ImagePickerResponse } from 'react-native-image-picker';
import { request, PERMISSIONS, RESULTS } from 'react-native-permissions';
import { Platform } from 'react-native';

interface UseImagePickerReturn {
  selectedImage: string | null;
  pickImage: () => Promise<void>;
  isLoading: boolean;
  error: string | null;
}

export const useImagePicker = (): UseImagePickerReturn => {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const requestPermission = async () => {
    const permission = Platform.OS === 'ios' 
      ? PERMISSIONS.IOS.PHOTO_LIBRARY 
      : PERMISSIONS.ANDROID.READ_EXTERNAL_STORAGE;
    
    const result = await request(permission);
    return result === RESULTS.GRANTED;
  };

  const pickImage = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      const hasPermission = await requestPermission();
      if (!hasPermission) {
        setError('Photo library permission required');
        return;
      }
      
      const result = await launchImageLibrary({
        mediaType: 'photo',
        quality: 0.8,
        maxWidth: 1000,
        maxHeight: 1000,
      });

      if (result.assets?.[0]?.uri) {
        setSelectedImage(result.assets[0].uri);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  };

  return { selectedImage, pickImage, isLoading, error };
};
```

---

## Performance Optimization

### FlatList Best Practices

```typescript
// Optimized FlatList component
const OptimizedList: React.FC<{ data: Item[] }> = ({ data }) => {
  // Pre-calculate item layout for better performance
  const getItemLayout = useCallback(
    (data: Item[] | null | undefined, index: number) => ({
      length: ITEM_HEIGHT,
      offset: ITEM_HEIGHT * index,
      index,
    }),
    []
  );

  const renderItem = useCallback(({ item }: { item: Item }) => (
    <MemoizedListItem item={item} />
  ), []);

  const keyExtractor = useCallback((item: Item) => item.id, []);

  const onViewableItemsChanged = useCallback(({ viewableItems }) => {
    // Handle visibility changes for analytics or lazy loading
  }, []);

  const viewabilityConfig = useMemo(() => ({
    viewAreaCoveragePercentThreshold: 50,
  }), []);

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      getItemLayout={getItemLayout}
      // Performance props
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      initialNumToRender={15}
      windowSize={21}
      // Memory management
      onViewableItemsChanged={onViewableItemsChanged}
      viewabilityConfig={viewabilityConfig}
    />
  );
};
```

### Image Optimization

```typescript
import FastImage from 'react-native-fast-image';

const OptimizedImage: React.FC<ImageProps> = ({ uri, style, ...props }) => (
  <FastImage
    source={{
      uri,
      priority: FastImage.priority.normal,
      cache: FastImage.cacheControl.immutable,
    }}
    style={style}
    resizeMode={FastImage.resizeMode.cover}
    {...props}
  />
);
```

### Animation with Native Driver

```typescript
import { useSharedValue, useAnimatedStyle, withTiming } from 'react-native-reanimated';

const AnimatedComponent: React.FC = () => {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(50);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      opacity: opacity.value,
      transform: [{ translateY: translateY.value }],
    };
  });

  const fadeIn = () => {
    opacity.value = withTiming(1, { duration: 300 });
    translateY.value = withTiming(0, { duration: 300 });
  };

  React.useEffect(() => {
    fadeIn();
  }, []);

  return (
    <Animated.View style={animatedStyle}>
      {/* Content */}
    </Animated.View>
  );
};
```

---

## State Management

### Zustand Store Pattern

```typescript
// stores/userStore.ts
import { create } from 'zustand';
import { devtools, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  users: User[];
  selectedUser: User | null;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  fetchUsers: () => Promise<void>;
  selectUser: (user: User) => void;
  updateUser: (userId: string, updates: Partial<User>) => void;
  clearError: () => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    subscribeWithSelector(
      immer((set, get) => ({
        users: [],
        selectedUser: null,
        isLoading: false,
        error: null,

        fetchUsers: async () => {
          set(state => {
            state.isLoading = true;
            state.error = null;
          });
          
          try {
            const users = await api.getUsers();
            set(state => {
              state.users = users;
              state.isLoading = false;
            });
          } catch (error) {
            set(state => {
              state.error = error.message;
              state.isLoading = false;
            });
          }
        },

        selectUser: (user) => set(state => {
          state.selectedUser = user;
        }),

        updateUser: (userId, updates) => set(state => {
          const index = state.users.findIndex(u => u.id === userId);
          if (index !== -1) {
            Object.assign(state.users[index], updates);
          }
        }),

        clearError: () => set(state => {
          state.error = null;
        }),
      }))
    )
  )
);
```

### React Query Integration

```typescript
// services/api/users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useUsers = (options?: { enabled?: boolean }) => {
  return useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    retry: 3,
    ...options,
  });
};

export const useUser = (userId: string) => {
  return useQuery({
    queryKey: ['users', userId],
    queryFn: () => fetchUser(userId),
    enabled: !!userId,
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: createUser,
    onMutate: async (newUser) => {
      // Optimistic update
      await queryClient.cancelQueries({ queryKey: ['users'] });
      
      const previousUsers = queryClient.getQueryData(['users']);
      
      queryClient.setQueryData(['users'], (old: User[]) => [
        ...old,
        { ...newUser, id: 'temp-' + Date.now() }
      ]);
      
      return { previousUsers };
    },
    onError: (err, newUser, context) => {
      // Rollback on error
      queryClient.setQueryData(['users'], context?.previousUsers);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};
```

---

## Navigation

### React Navigation Setup

```typescript
// navigation/AppNavigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useColorScheme } from 'react-native';

import { HomeScreen, ProfileScreen, SettingsScreen } from '../screens';
import { Colors } from '../styles/colors';

export type RootStackParamList = {
  Main: undefined;
  Profile: { userId: string };
  Settings: undefined;
};

export type TabParamList = {
  Home: undefined;
  Search: undefined;
  Profile: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

const TabNavigator = () => {
  const colorScheme = useColorScheme();
  
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: Colors[colorScheme ?? 'light'].tint,
        headerShown: false,
      }}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
};

export const AppNavigator: React.FC = () => {
  const colorScheme = useColorScheme();
  
  return (
    <NavigationContainer
      theme={colorScheme === 'dark' ? DarkTheme : DefaultTheme}
    >
      <Stack.Navigator
        screenOptions={{
          headerStyle: {
            backgroundColor: Colors[colorScheme ?? 'light'].background,
          },
          headerTintColor: Colors[colorScheme ?? 'light'].text,
        }}
      >
        <Stack.Screen 
          name="Main" 
          component={TabNavigator}
          options={{ headerShown: false }}
        />
        <Stack.Screen 
          name="Profile" 
          component={ProfileScreen}
          options={({ route }) => ({ 
            title: `User ${route.params.userId}` 
          })}
        />
        <Stack.Screen name="Settings" component={SettingsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

### Deep Linking

```typescript
// navigation/linking.ts
import { LinkingOptions } from '@react-navigation/native';
import { RootStackParamList } from './AppNavigator';

const linking: LinkingOptions<RootStackParamList> = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Main: {
        screens: {
          Home: '',
          Search: 'search',
          Profile: 'profile',
        },
      },
      Profile: 'user/:userId',
      Settings: 'settings',
    },
  },
  async getInitialURL() {
    // Handle cold start deep links
    const url = await Linking.getInitialURL();
    return url;
  },
  subscribe(listener) {
    // Handle warm start deep links
    const onReceiveURL = ({ url }: { url: string }) => listener(url);
    const subscription = Linking.addEventListener('url', onReceiveURL);
    return () => subscription?.remove();
  },
};

export default linking;
```

### Navigation Hooks

```typescript
// hooks/useNavigation.ts
import { useNavigation as useRNNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export const useNavigation = () => {
  return useRNNavigation<NavigationProp>();
};

// Usage in components
const SomeComponent = () => {
  const navigation = useNavigation();
  
  const navigateToProfile = (userId: string) => {
    navigation.navigate('Profile', { userId });
  };
  
  return (
    // Component JSX
  );
};
```

---

## Platform-Specific Code

### Platform-Specific Styling

```typescript
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    padding: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  text: {
    fontSize: Platform.OS === 'ios' ? 16 : 14,
    fontFamily: Platform.select({
      ios: 'SF Pro Text',
      android: 'Roboto',
    }),
  },
  safeArea: {
    paddingTop: Platform.OS === 'ios' ? 44 : 0,
  },
});
```

### Platform-Specific Components

```typescript
// components/StatusBar/StatusBar.ios.tsx
import React from 'react';
import { StatusBar as RNStatusBar } from 'react-native';

const StatusBar: React.FC = () => (
  <RNStatusBar barStyle="dark-content" backgroundColor="transparent" />
);

export default StatusBar;

// components/StatusBar/StatusBar.android.tsx
import React from 'react';
import { StatusBar as RNStatusBar } from 'react-native';

const StatusBar: React.FC = () => (
  <RNStatusBar barStyle="light-content" backgroundColor="#6200ea" />
);

export default StatusBar;

// components/StatusBar/index.ts
import { Platform } from 'react-native';

export { default } from Platform.select({
  ios: () => require('./StatusBar.ios').default,
  android: () => require('./StatusBar.android').default,
})();
```

### Safe Area Handling

```typescript
import React from 'react';
import { View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface SafeAreaViewProps {
  children: React.ReactNode;
  edges?: ('top' | 'bottom' | 'left' | 'right')[];
}

const SafeAreaView: React.FC<SafeAreaViewProps> = ({ 
  children, 
  edges = ['top', 'bottom', 'left', 'right'] 
}) => {
  const insets = useSafeAreaInsets();
  
  const paddingStyle = {
    paddingTop: edges.includes('top') ? insets.top : 0,
    paddingBottom: edges.includes('bottom') ? insets.bottom : 0,
    paddingLeft: edges.includes('left') ? insets.left : 0,
    paddingRight: edges.includes('right') ? insets.right : 0,
  };
  
  return (
    <View style={[{ flex: 1 }, paddingStyle]}>
      {children}
    </View>
  );
};
```

---

## Styling Approaches

### StyleSheet with Design Tokens

```typescript
// styles/tokens.ts
export const tokens = {
  colors: {
    primary: '#007AFF',
    secondary: '#5856D6',
    success: '#34C759',
    warning: '#FF9500',
    error: '#FF3B30',
    background: '#FFFFFF',
    surface: '#F2F2F7',
    text: '#000000',
    textSecondary: '#8E8E93',
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
  },
  typography: {
    h1: { fontSize: 32, fontWeight: 'bold', lineHeight: 40 },
    h2: { fontSize: 24, fontWeight: 'bold', lineHeight: 32 },
    h3: { fontSize: 20, fontWeight: '600', lineHeight: 28 },
    body: { fontSize: 16, fontWeight: 'normal', lineHeight: 24 },
    caption: { fontSize: 12, fontWeight: 'normal', lineHeight: 16 },
  },
  borderRadius: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
  },
} as const;
```

### Style Hooks Pattern

```typescript
// hooks/useStyles.ts
import { useMemo } from 'react';
import { StyleSheet, useColorScheme } from 'react-native';
import { tokens } from '../styles/tokens';

interface ButtonStylesProps {
  variant: 'primary' | 'secondary';
  size: 'small' | 'medium' | 'large';
  disabled: boolean;
}

export const useButtonStyles = ({ variant, size, disabled }: ButtonStylesProps) => {
  const colorScheme = useColorScheme();
  
  return useMemo(() => {
    const colors = colorScheme === 'dark' ? tokens.darkColors : tokens.colors;
    
    return StyleSheet.create({
      container: {
        backgroundColor: disabled 
          ? colors.disabled 
          : colors[variant],
        paddingHorizontal: tokens.spacing[size === 'small' ? 'md' : 'lg'],
        paddingVertical: tokens.spacing[size === 'small' ? 'sm' : 'md'],
        borderRadius: tokens.borderRadius.md,
        opacity: disabled ? 0.5 : 1,
        alignItems: 'center',
        justifyContent: 'center',
      },
      text: {
        ...tokens.typography[size === 'small' ? 'caption' : 'body'],
        color: colors.onPrimary,
        textAlign: 'center',
      },
    });
  }, [variant, size, disabled, colorScheme]);
};
```

### Responsive Design

```typescript
import { Dimensions, StyleSheet } from 'react-native';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

export const useResponsiveStyles = () => {
  const isTablet = screenWidth >= 768;
  const isLandscape = screenWidth > screenHeight;
  
  return StyleSheet.create({
    container: {
      flexDirection: isTablet ? 'row' : 'column',
      padding: isTablet ? 24 : 16,
    },
    sidebar: {
      width: isTablet ? 300 : '100%',
      display: isTablet || isLandscape ? 'flex' : 'none',
    },
    content: {
      flex: 1,
      marginLeft: isTablet ? 16 : 0,
      marginTop: isTablet ? 0 : 16,
    },
  });
};
```

---

## Native Modules

### Creating a TurboModule

```typescript
// specs/NativeCalendarModule.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  createCalendarEvent(name: string, location: string): Promise<number>;
  getName(): string;
}

export default TurboModuleRegistry.getEnforcing<Spec>('CalendarModule');
```

### Using Native Modules

```typescript
// services/CalendarService.ts
import NativeCalendarModule from '../specs/NativeCalendarModule';

export class CalendarService {
  static async createEvent(name: string, location: string): Promise<number> {
    try {
      return await NativeCalendarModule.createCalendarEvent(name, location);
    } catch (error) {
      console.error('Failed to create calendar event:', error);
      throw error;
    }
  }

  static getModuleName(): string {
    return NativeCalendarModule.getName();
  }
}
```

### Bridging Existing Libraries

```typescript
// Using react-native-keychain
import * as Keychain from 'react-native-keychain';

export const secureStorage = {
  async setItem(key: string, value: string): Promise<void> {
    try {
      await Keychain.setInternetCredentials(key, key, value);
    } catch (error) {
      console.error('Failed to save to keychain:', error);
    }
  },

  async getItem(key: string): Promise<string | null> {
    try {
      const credentials = await Keychain.getInternetCredentials(key);
      return credentials ? credentials.password : null;
    } catch (error) {
      console.error('Failed to retrieve from keychain:', error);
      return null;
    }
  },

  async removeItem(key: string): Promise<void> {
    try {
      await Keychain.resetInternetCredentials(key);
    } catch (error) {
      console.error('Failed to remove from keychain:', error);
    }
  },
};
```

---

## Testing Strategies

### Jest + React Native Testing Library

```typescript
// __tests__/components/Button.test.tsx
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import Button from '../../src/components/Button';

describe('Button Component', () => {
  it('renders correctly with primary variant', () => {
    const { getByText, getByRole } = render(
      <Button variant="primary" onPress={jest.fn()}>
        Click Me
      </Button>
    );
    
    expect(getByText('Click Me')).toBeTruthy();
    expect(getByRole('button')).toBeTruthy();
  });

  it('calls onPress when pressed', () => {
    const mockOnPress = jest.fn();
    const { getByRole } = render(
      <Button onPress={mockOnPress}>
        Click Me
      </Button>
    );
    
    fireEvent.press(getByRole('button'));
    expect(mockOnPress).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    const mockOnPress = jest.fn();
    const { getByRole } = render(
      <Button disabled onPress={mockOnPress}>
        Click Me
      </Button>
    );
    
    const button = getByRole('button');
    expect(button.props.accessibilityState.disabled).toBe(true);
    
    fireEvent.press(button);
    expect(mockOnPress).not.toHaveBeenCalled();
  });
});
```

### Integration Testing with MSW

```typescript
// __tests__/screens/UserList.test.tsx
import React from 'react';
import { render, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { setupServer } from 'msw/node';
import { rest } from 'msw';
import { NavigationContainer } from '@react-navigation/native';
import UserListScreen from '../../src/screens/UserListScreen';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([
      { id: '1', name: 'John Doe', email: 'john@example.com' },
      { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
    ]));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>
        {children}
      </NavigationContainer>
    </QueryClientProvider>
  );
};

test('displays users after loading', async () => {
  const { getByText } = render(<UserListScreen />, { wrapper: createWrapper() });
  
  await waitFor(() => {
    expect(getByText('John Doe')).toBeTruthy();
    expect(getByText('Jane Smith')).toBeTruthy();
  });
});
```

### E2E Testing with Detox

```typescript
// e2e/app.test.ts
import { by, device, element, expect } from 'detox';

describe('App E2E Tests', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show home screen after launch', async () => {
    await expect(element(by.id('home-screen'))).toBeVisible();
  });

  it('should navigate to profile screen', async () => {
    await element(by.id('profile-button')).tap();
    await expect(element(by.id('profile-screen'))).toBeVisible();
  });

  it('should handle user input', async () => {
    await element(by.id('name-input')).typeText('John Doe');
    await element(by.id('submit-button')).tap();
    await expect(element(by.text('Welcome, John Doe!'))).toBeVisible();
  });
});
```

---

## Accessibility

### Comprehensive Accessibility Implementation

```typescript
const AccessibleButton: React.FC<ButtonProps> = ({
  children,
  onPress,
  disabled = false,
  accessibilityLabel,
  accessibilityHint,
  ...props
}) => (
  <Pressable
    onPress={onPress}
    disabled={disabled}
    accessible={true}
    accessibilityRole="button"
    accessibilityLabel={accessibilityLabel || (typeof children === 'string' ? children : undefined)}
    accessibilityHint={accessibilityHint}
    accessibilityState={{ 
      disabled,
      busy: false 
    }}
    importantForAccessibility="yes"
    {...props}
  >
    {children}
  </Pressable>
);
```

### Screen Reader Support

```typescript
const AccessibleForm: React.FC = () => {
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState('');

  return (
    <View>
      <Text 
        accessibilityRole="header" 
        accessible={true}
        style={styles.title}
      >
        Login Form
      </Text>
      
      <TextInput
        value={email}
        onChangeText={setEmail}
        placeholder="Enter your email"
        accessibilityLabel="Email address"
        accessibilityHint="Enter your email to sign in"
        accessibilityValue={{ text: email }}
        accessibilityInvalid={!!emailError}
        accessibilityErrorMessage={emailError}
        importantForAccessibility="yes"
        style={styles.input}
      />
      
      {emailError && (
        <Text 
          accessibilityRole="alert"
          style={styles.errorText}
        >
          {emailError}
        </Text>
      )}
    </View>
  );
};
```

### Dynamic Type Support

```typescript
import { useWindowDimensions, PixelRatio } from 'react-native';

const useDynamicType = () => {
  const { fontScale } = useWindowDimensions();
  
  const getFontSize = (baseSize: number) => {
    return PixelRatio.roundToNearestPixel(baseSize * fontScale);
  };
  
  const isLargeText = fontScale > 1.2;
  const isExtraLargeText = fontScale > 1.5;
  
  return {
    getFontSize,
    isLargeText,
    isExtraLargeText,
    fontScale,
  };
};
```

---

## Build & Deployment

### Hermes Configuration

```javascript
// metro.config.js
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const config = {
  transformer: {
    hermesCommand: './node_modules/react-native/sdks/hermesc/osx-bin/hermesc',
    minifierConfig: {
      mangle: {
        keep_fnames: true,
      },
      output: {
        ascii_only: true,
        quote_keys: true,
        wrap_iife: true,
      },
    },
  },
  resolver: {
    assetExts: ['db', 'mp3', 'ttf', 'obj', 'png', 'jpg', 'svg'],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

### Code Signing (iOS)

```bash
# Install certificates
security import certificate.p12 -k ~/Library/Keychains/login.keychain -P password

# Build for release
npx react-native run-ios --configuration Release
```

### Android Release Build

```bash
# Generate keystore
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
cd android
./gradlew assembleRelease

# Build AAB for Play Store
./gradlew bundleRelease
```

### Bundle Analysis

```bash
# Analyze bundle size
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android-bundle.js --assets-dest android-assets

# Use bundle visualizer
npm install --save-dev react-native-bundle-visualizer
npx react-native-bundle-visualizer
```

---

## Best Practices

### Performance
- Use FlatList with proper optimization props (`getItemLayout`, `removeClippedSubviews`)
- Implement memoization with React.memo, useMemo, and useCallback
- Enable Hermes engine for better performance
- Use native driver for animations (Reanimated 3)
- Optimize images with proper formats and sizes

### Code Quality
- Use TypeScript with strict mode enabled
- Follow consistent naming conventions
- Implement comprehensive error boundaries
- Use proper prop validation and default values
- Keep components focused and single-responsibility

### Architecture
- Adopt new React Native architecture (Fabric + TurboModules) when stable
- Use proper state management (Zustand for client state, React Query for server state)
- Implement clean component composition patterns
- Follow platform-specific design guidelines (iOS Human Interface, Android Material)
- Use proper navigation patterns with React Navigation

### Development Experience
- Set up proper TypeScript configuration with path mapping
- Use consistent code formatting (ESLint + Prettier)
- Implement proper testing strategy (unit, integration, E2E)
- Use debugging tools effectively (Flipper, React DevTools)
- Keep dependencies updated and secure

### Security
- Store sensitive data in Keychain/Keystore
- Implement proper authentication and authorization
- Use HTTPS for all network requests
- Validate all user inputs
- Implement certificate pinning for sensitive apps

### Deployment
- Use proper CI/CD pipelines
- Implement proper environment configuration
- Use over-the-air updates when appropriate
- Monitor app performance and crash reports
- Follow app store guidelines and best practices

This guide provides a comprehensive foundation for modern React Native development, emphasizing performance, maintainability, and developer experience while being framework-agnostic and applicable to any React Native project structure.