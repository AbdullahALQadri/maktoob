import { useState } from 'react';
import { Home } from './components/pages/Home';
import { Events } from './components/pages/Events';
import { CreateEvent } from './components/pages/CreateEvent';
import { Venue } from './components/pages/Venue';
import { QRScanner } from './components/pages/QRScanner';
import { PaymentUpload } from './components/pages/PaymentUpload';
import { EventDetails } from './components/pages/EventDetails';
import { Navigation } from './components/Navigation';

export default function App() {
  const [currentPage, setCurrentPage] = useState('home');
  const [eventId, setEventId] = useState<string | null>(null);

  const renderPage = () => {
    switch (currentPage) {
      case 'home':
        return <Home />;
      case 'events':
        return <Events 
          onUploadPayment={(id) => {
            setEventId(id);
            setCurrentPage('payment');
          }}
          onViewEvent={(id) => {
            setEventId(id);
            setCurrentPage('event-details');
          }}
        />;
      case 'create':
        return <CreateEvent onComplete={(id) => {
          setEventId(id);
          setCurrentPage('payment');
        }} />;
      case 'venue':
        return <Venue />;
      case 'scanner':
        return <QRScanner />;
      case 'payment':
        return <PaymentUpload eventId={eventId} onComplete={() => setCurrentPage('events')} />;
      case 'event-details':
        return <EventDetails eventId={eventId || ''} onBack={() => setCurrentPage('events')} />;
      default:
        return <Home />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-blue-50 pb-24 max-w-[393px] mx-auto">
      {renderPage()}
      <Navigation currentPage={currentPage} onPageChange={setCurrentPage} />
    </div>
  );
}