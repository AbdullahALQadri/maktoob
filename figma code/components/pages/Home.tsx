import { Users, Calendar, CheckCircle, XCircle, Clock, TrendingUp, Sparkles, ArrowRight } from 'lucide-react';
import { motion } from 'motion/react';

export function Home() {
  const stats = [
    { label: 'Total Events', value: '24', icon: Calendar, color: 'from-purple-500 to-purple-600', bgColor: 'bg-purple-500' },
    { label: 'Total Guests', value: '1,234', icon: Users, color: 'from-blue-500 to-blue-600', bgColor: 'bg-blue-500' },
    { label: 'Attending', value: '892', icon: CheckCircle, color: 'from-green-500 to-green-600', bgColor: 'bg-green-500' },
    { label: 'Not Attending', value: '156', icon: XCircle, color: 'from-red-500 to-red-600', bgColor: 'bg-red-500' },
  ];

  const recentEvents = [
    {
      id: 1,
      name: 'Wedding Ceremony',
      date: '2026-01-15',
      venue: 'Grand Hotel Ballroom',
      invitations: 150,
      responses: 120,
      attending: 95,
      gradient: 'from-pink-500 to-rose-500',
    },
    {
      id: 2,
      name: 'Corporate Gala',
      date: '2026-01-20',
      venue: 'Convention Center',
      invitations: 300,
      responses: 180,
      attending: 165,
      gradient: 'from-blue-500 to-cyan-500',
    },
    {
      id: 3,
      name: 'Birthday Party',
      date: '2026-01-25',
      venue: 'Beach Resort',
      invitations: 80,
      responses: 65,
      attending: 58,
      gradient: 'from-amber-500 to-orange-500',
    },
  ];

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
    hidden: { y: 20, opacity: 0 },
    show: { y: 0, opacity: 1 }
  };

  return (
    <div className="min-h-screen">
      {/* Header with Gradient */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-purple-600 via-purple-700 to-blue-600 text-white px-6 pt-12 pb-24 relative overflow-hidden"
      >
        {/* Animated Background Circles */}
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            rotate: [0, 180, 360],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -top-20 -right-20 w-60 h-60 bg-white/10 rounded-full blur-3xl"
        />
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            rotate: [360, 180, 0],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute -bottom-10 -left-10 w-60 h-60 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-4 py-2 rounded-full mb-4"
          >
            <Sparkles className="w-4 h-4" />
            <span className="text-sm font-medium">Welcome back!</span>
          </motion.div>
          <h1 className="text-3xl font-bold mb-2">Koroot Dashboard</h1>
          <p className="text-purple-100 text-sm">Manage your events beautifully</p>
        </div>
      </motion.div>

      {/* Stats Grid - Overlapping Header */}
      <motion.div 
        variants={container}
        initial="hidden"
        animate="show"
        className="px-6 -mt-16 relative z-20"
      >
        <div className="grid grid-cols-2 gap-3">
          {stats.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <motion.div
                key={stat.label}
                variants={item}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="bg-white rounded-3xl p-5 shadow-xl shadow-purple-100"
              >
                <motion.div 
                  initial={{ scale: 0, rotate: -180 }}
                  animate={{ scale: 1, rotate: 0 }}
                  transition={{ delay: 0.3 + index * 0.1, type: "spring" }}
                  className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${stat.color} flex items-center justify-center mb-3 shadow-lg`}
                >
                  <Icon className="w-6 h-6 text-white" />
                </motion.div>
                <motion.p 
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.5 + index * 0.1 }}
                  className="text-3xl font-bold text-gray-900 mb-1"
                >
                  {stat.value}
                </motion.p>
                <p className="text-xs text-gray-600 font-medium">{stat.label}</p>
              </motion.div>
            );
          })}
        </div>
      </motion.div>

      {/* Response Rate Card */}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="px-6 mt-6"
      >
        <motion.div 
          whileHover={{ scale: 1.02 }}
          className="bg-gradient-to-br from-purple-600 to-blue-600 rounded-3xl p-6 shadow-xl text-white relative overflow-hidden"
        >
          <motion.div
            animate={{
              x: [-100, 400],
              y: [-100, 100],
            }}
            transition={{
              duration: 8,
              repeat: Infinity,
              repeatType: "reverse"
            }}
            className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full blur-2xl"
          />
          <div className="relative z-10">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-lg">Response Rate</h3>
              <motion.div
                animate={{ rotate: [0, 360] }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              >
                <TrendingUp className="w-6 h-6" />
              </motion.div>
            </div>
            <div className="flex items-end gap-3 mb-4">
              <motion.span 
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.8, type: "spring" }}
                className="text-5xl font-bold"
              >
                85%
              </motion.span>
              <span className="text-green-300 text-sm mb-2 font-medium">+12% this month</span>
            </div>
            <div className="w-full bg-white/20 rounded-full h-3 backdrop-blur-sm overflow-hidden">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: '85%' }}
                transition={{ delay: 1, duration: 1, ease: "easeOut" }}
                className="bg-white h-3 rounded-full shadow-lg"
              />
            </div>
          </div>
        </motion.div>
      </motion.div>

      {/* Recent Events */}
      <div className="px-6 mt-8 pb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-900">Recent Events</h2>
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="text-purple-600 text-sm font-medium flex items-center gap-1"
          >
            View All
            <ArrowRight className="w-4 h-4" />
          </motion.button>
        </div>
        
        <motion.div 
          variants={container}
          initial="hidden"
          animate="show"
          className="space-y-4"
        >
          {recentEvents.map((event, index) => (
            <motion.div
              key={event.id}
              variants={item}
              whileHover={{ scale: 1.02, y: -4 }}
              whileTap={{ scale: 0.98 }}
              className="bg-white rounded-3xl p-5 shadow-lg shadow-gray-200/50 relative overflow-hidden group"
            >
              {/* Gradient Accent */}
              <div className={`absolute top-0 left-0 w-1.5 h-full bg-gradient-to-b ${event.gradient}`} />
              
              <div className="ml-3">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <h3 className="font-bold text-gray-900 text-lg">{event.name}</h3>
                    <p className="text-sm text-gray-600 mt-1 flex items-center gap-1.5">
                      <Calendar className="w-4 h-4" />
                      {new Date(event.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </p>
                    <p className="text-sm text-gray-600 mt-1 flex items-center gap-1.5">
                      <Clock className="w-4 h-4" />
                      {event.venue}
                    </p>
                  </div>
                  <motion.span 
                    whileHover={{ rotate: 90 }}
                    className="bg-purple-100 text-purple-700 p-2 rounded-full"
                  >
                    <ArrowRight className="w-4 h-4" />
                  </motion.span>
                </div>
                
                {/* Progress */}
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600 font-medium">Responses</span>
                    <span className="font-bold text-gray-900">{event.responses}/{event.invitations}</span>
                  </div>
                  <div className="w-full bg-gray-100 rounded-full h-2 overflow-hidden">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: `${(event.responses / event.invitations) * 100}%` }}
                      transition={{ delay: 1.2 + index * 0.2, duration: 0.8 }}
                      className={`bg-gradient-to-r ${event.gradient} h-2 rounded-full shadow-sm`}
                    />
                  </div>
                  <div className="flex gap-4 mt-3">
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full bg-green-500"></div>
                      <span className="text-xs text-gray-600 font-medium">{event.attending} Attending</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full bg-gray-300"></div>
                      <span className="text-xs text-gray-600 font-medium">{event.responses - event.attending} Other</span>
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </div>
  );
}
