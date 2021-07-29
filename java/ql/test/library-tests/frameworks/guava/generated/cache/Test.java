package generatedtest;

import com.google.common.cache.Cache;
import com.google.common.cache.LoadingCache;
import com.google.common.cache.CacheBuilder;
import com.google.common.collect.ImmutableMap;
import java.util.Map;
import java.util.concurrent.ConcurrentMap;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

// Test case generated by GenerateFlowTestCase.ql
public class Test {

	<K,V> K getMapKey(Map<K,V> container) { return container.keySet().iterator().next(); }
	<K,V> K getMapKey(Cache<K,V> container) { return getMapKey(container.asMap()); }
	<K,V> V getMapValue(Map<K,V> container) { return container.values().iterator().next(); }
	<K,V> V getMapValue(Cache<K,V> container) { return getMapValue(container.asMap()); }
	<T> Iterable<T> newWithElement(T element) { 
		List<T> l = new ArrayList();
		l.add(element);
		return l;
	}
	<K,V> Map<K,V> newMapWithMapKey(K element) { 
		Map<K,V> m = new HashMap<K,V>();
		m.put(element, null);
		return m;
	} 
	<K,V> LoadingCache<K,V> newCacheWithMapKey(K element) { 
		LoadingCache<K,V> lc = CacheBuilder.newBuilder().build(null);
		lc.put(element, null);
		return lc;
	}
	<K,V> Map<K,V> newMapWithMapValue(V element) { 
		Map<K,V> m = new HashMap<K,V>();
		m.put(null, element);
		return m;
	 } 
	<K,V> LoadingCache<K,V> newCacheWithMapValue(V element) { 
		LoadingCache<K,V> lc = CacheBuilder.newBuilder().build(null);
		lc.put(null, element);
		return lc;
	}
	<T> T source() { return null; }
	void sink(Object o) { }

	public void test() throws Exception {

		{
			// "com.google.common.cache;Cache;true;asMap;();;MapKey of Argument[-1];MapKey of ReturnValue;value"
			ConcurrentMap out = null;
			LoadingCache in = newCacheWithMapKey(source());
			out = in.asMap();
			sink(getMapKey(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;asMap;();;MapKey of Argument[-1];MapKey of ReturnValue;value"
			ConcurrentMap out = null;
			Cache in = newCacheWithMapKey(source());
			out = in.asMap();
			sink(getMapKey(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;asMap;();;MapValue of Argument[-1];MapValue of ReturnValue;value"
			ConcurrentMap out = null;
			LoadingCache in = newCacheWithMapValue(source());
			out = in.asMap();
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;asMap;();;MapValue of Argument[-1];MapValue of ReturnValue;value"
			ConcurrentMap out = null;
			Cache in = newCacheWithMapValue(source());
			out = in.asMap();
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;get;(Object,Callable);;MapValue of Argument[-1];ReturnValue;value"
			Object out = null;
			Cache in = newCacheWithMapValue(source());
			out = in.get(null, null);
			sink(out); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;getAllPresent;(Iterable);;MapValue of Argument[-1];MapValue of ReturnValue;value"
			ImmutableMap out = null;
			Cache in = newCacheWithMapValue(source());
			out = in.getAllPresent(null);
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;getIfPresent;;;MapValue of Argument[-1];ReturnValue;value"
			Object out = null;
			Cache in = newCacheWithMapValue(source());
			out = in.getIfPresent(null);
			sink(out); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;put;(Object,Object);;Argument[0];MapKey of Argument[-1];value"
			Cache out = null;
			Object in = source();
			out.put(in, null);
			sink(getMapKey(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;put;(Object,Object);;Argument[1];MapValue of Argument[-1];value"
			Cache out = null;
			Object in = source();
			out.put(null, in);
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;putAll;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value"
			Cache out = null;
			Map in = newMapWithMapKey(source());
			out.putAll(in);
			sink(getMapKey(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;Cache;true;putAll;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value"
			Cache out = null;
			Map in = newMapWithMapValue(source());
			out.putAll(in);
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;LoadingCache;true;apply;;;MapValue of Argument[-1];ReturnValue;value"
			Object out = null;
			LoadingCache in = newCacheWithMapValue(source());
			out = in.apply(null);
			sink(out); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;LoadingCache;true;get;;;MapValue of Argument[-1];ReturnValue;value"
			Object out = null;
			LoadingCache in = newCacheWithMapValue(source());
			out = in.get(null);
			sink(out); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;LoadingCache;true;getAll;(Iterable);;Element of Argument[0];MapKey of ReturnValue;value"
			ImmutableMap out = null;
			Iterable in = newWithElement(source());
			LoadingCache instance = null;
			out = instance.getAll(in);
			sink(getMapKey(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;LoadingCache;true;getAll;(Iterable);;MapValue of Argument[-1];MapValue of ReturnValue;value"
			ImmutableMap out = null;
			LoadingCache in = newCacheWithMapValue(source());
			out = in.getAll(null);
			sink(getMapValue(out)); // $ hasValueFlow
		}
		{
			// "com.google.common.cache;LoadingCache;true;getUnchecked;;;MapValue of Argument[-1];ReturnValue;value"
			Object out = null;
			LoadingCache in = newCacheWithMapValue(source());
			out = in.getUnchecked(null);
			sink(out); // $ hasValueFlow
		}

	}

}