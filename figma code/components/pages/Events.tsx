import { Search, Calendar, MapPin, Users, ArrowRight, Filter, Sparkles, Upload } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

export function Events({ onUploadPayment, onViewEvent }: { onUploadPayment: (eventId: string) => void; onViewEvent: (eventId: string) => void }) {
  const [searchQuery, setSearchQuery] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  const events = [
    {
      id: '1',
      name: 'Wedding Ceremony',
      type: 'Wedding',
      date: '2026-01-15',
      time: '18:00',
      venue: 'Grand Hotel Ballroom',
      invitations: 150,
      responses: 120,
      attending: 95,
      status: 'active',
      gradient: 'from-pink-500 to-rose-500',
      icon: '💒',
    },
    {
      id: '2',
      name: 'Corporate Gala',
      type: 'Corporate',
      date: '2026-01-20',
      time: '19:30',
      venue: 'Convention Center',
      invitations: 300,
      responses: 180,
      attending: 165,
      status: 'active',
      gradient: 'from-blue-500 to-cyan-500',
      icon: '🏢',
    },
    {
      id: '3',
      name: 'Birthday Party',
      type: 'Birthday',
      date: '2026-01-25',
      time: '16:00',
      venue: 'Beach Resort',
      invitations: 80,
      responses: 65,
      attending: 58,
      status: 'inactive',
      gradient: 'from-amber-500 to-orange-500',
      icon: '🎂',
    },
    {
      id: '4',
      name: 'Graduation Ceremony',
      type: 'Graduation',
      date: '2026-02-01',
      time: '10:00',
      venue: 'University Hall',
      invitations: 200,
      responses: 45,
      attending: 40,
      status: 'draft',
      gradient: 'from-green-500 to-emerald-500',
      icon: '🎓',
    },
    {
      id: '5',
      name: 'Charity Fundraiser',
      type: 'Charity',
      date: '2025-12-20',
      time: '18:00',
      venue: 'City Center',
      invitations: 250,
      responses: 250,
      attending: 200,
      status: 'completed',
      gradient: 'from-purple-500 to-indigo-500',
      icon: '❤️',
    },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-500';
      case 'inactive':
        return 'bg-orange-500';
      case 'draft':
        return 'bg-yellow-500';
      case 'completed':
        return 'bg-gray-400';
      default:
        return 'bg-gray-400';
    }
  };

  const filteredEvents = events.filter(event => {
    const matchesSearch = event.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         event.type.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filterStatus === 'all' || event.status === filterStatus;
    return matchesSearch && matchesFilter;
  });

  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const item = {
    hidden: { x: -20, opacity: 0 },
    show: { x: 0, opacity: 1 }
  };

  return (
    <div className="min-h-screen">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-blue-600 via-purple-600 to-purple-700 text-white px-6 pt-12 pb-8 relative overflow-hidden"
      >
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            rotate: [0, 90, 0],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full mb-3"
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">{filteredEvents.length} Events</span>
          </motion.div>
          <h1 className="text-3xl font-bold mb-6">Events</h1>
          
          {/* Search Bar */}
          <motion.div 
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="relative"
          >
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-purple-300" />
            <input
              type="text"
              placeholder="Search events..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3.5 bg-white/20 backdrop-blur-md border border-white/30 rounded-2xl text-white placeholder-purple-200 focus:outline-none focus:ring-2 focus:ring-white/50 focus:bg-white/30 transition-all"
            />
          </motion.div>

          {/* Filter Tabs */}
          <motion.div 
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="flex gap-2 overflow-x-auto pb-1 mt-4 scrollbar-hide"
          >
            {['all', 'active', 'draft', 'completed'].map((status, index) => (
              <motion.button
                key={status}
                onClick={() => setFilterStatus(status)}
                whileTap={{ scale: 0.95 }}
                className={`px-5 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all ${
                  filterStatus === status
                    ? 'bg-white text-purple-600 shadow-lg'
                    : 'bg-white/20 text-white backdrop-blur-sm'
                }`}
              >
                {status.charAt(0).toUpperCase() + status.slice(1)}
              </motion.button>
            ))}
          </motion.div>
        </div>
      </motion.div>

      {/* Events List */}
      <motion.div 
        variants={container}
        initial="hidden"
        animate="show"
        className="px-6 py-6 space-y-4"
      >
        <AnimatePresence>
          {filteredEvents.map((event, index) => (
            <motion.div
              key={event.id}
              variants={item}
              layout
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
              whileHover={{ scale: 1.02, y: -4 }}
              whileTap={{ scale: 0.98 }}
              transition={{ type: "spring", bounce: 0.3 }}
              className="bg-white rounded-3xl p-6 shadow-xl shadow-gray-200/50 relative overflow-hidden"
            >
              {/* Gradient Background */}
              <div className={`absolute top-0 right-0 w-32 h-32 bg-gradient-to-br ${event.gradient} opacity-10 rounded-full blur-2xl`} />
              
              <div className="relative z-10">
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-start gap-3">
                    <motion.div 
                      whileHover={{ rotate: 360 }}
                      transition={{ duration: 0.5 }}
                      className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${event.gradient} flex items-center justify-center text-2xl shadow-lg`}
                    >
                      {event.icon}
                    </motion.div>
                    <div>
                      <h3 className="font-bold text-gray-900 text-lg">{event.name}</h3>
                      <span className="inline-block mt-1.5 text-xs px-3 py-1 rounded-full bg-purple-50 text-purple-700 font-medium">
                        {event.type}
                      </span>
                    </div>
                  </div>
                  <motion.div 
                    whileHover={{ scale: 1.2, rotate: 90 }}
                    className="flex flex-col items-end gap-2"
                  >
                    <div className={`w-3 h-3 rounded-full ${getStatusColor(event.status)} shadow-lg`} />
                  </motion.div>
                </div>

                <div className="space-y-3 mb-4">
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <div className="w-8 h-8 rounded-xl bg-blue-50 flex items-center justify-center">
                      <Calendar className="w-4 h-4 text-blue-600" />
                    </div>
                    <span className="font-medium">{new Date(event.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })} at {event.time}</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center">
                      <MapPin className="w-4 h-4 text-purple-600" />
                    </div>
                    <span className="font-medium">{event.venue}</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <div className="w-8 h-8 rounded-xl bg-green-50 flex items-center justify-center">
                      <Users className="w-4 h-4 text-green-600" />
                    </div>
                    <span className="font-medium">{event.invitations} Invitations</span>
                  </div>
                </div>

                {/* Response Progress */}
                <div className="bg-gray-50 rounded-2xl p-4">
                  <div className="flex justify-between text-sm mb-2">
                    <span className="text-gray-600 font-medium">Response Rate</span>
                    <span className="font-bold text-gray-900">{event.responses}/{event.invitations}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden mb-3">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: `${(event.responses / event.invitations) * 100}%` }}
                      transition={{ delay: 0.5 + index * 0.1, duration: 0.8, ease: "easeOut" }}
                      className={`bg-gradient-to-r ${event.gradient} h-2.5 rounded-full shadow-sm`}
                    />
                  </div>
                  <div className="flex justify-between items-center">
                    <div className="flex gap-3">
                      <div className="flex items-center gap-1.5">
                        <div className="w-2.5 h-2.5 rounded-full bg-green-500"></div>
                        <span className="text-xs text-gray-600 font-medium">{event.attending}</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <div className="w-2.5 h-2.5 rounded-full bg-gray-300"></div>
                        <span className="text-xs text-gray-600 font-medium">{event.responses - event.attending}</span>
                      </div>
                    </div>
                    {event.status === 'inactive' ? (
                      <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => onUploadPayment(event.id)}
                        className="flex items-center gap-1.5 bg-orange-600 text-white text-xs px-3 py-1.5 rounded-lg font-semibold shadow-md"
                      >
                        <Upload className="w-3.5 h-3.5" />
                        Upload Invoice
                      </motion.button>
                    ) : (
                      <motion.button
                        whileHover={{ x: 5 }}
                        onClick={() => onViewEvent(event.id)}
                        className="flex items-center gap-1 text-purple-600 text-sm font-semibold"
                      >
                        View
                        <ArrowRight className="w-4 h-4" />
                      </motion.button>
                    )}
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}